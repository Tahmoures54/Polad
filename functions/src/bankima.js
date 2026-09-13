/**
 * آداپتور HTTP بانکیما.
 *
 * باهمتا تعطیل است. اسرار فقط در env توابع می‌مانند.
 *
 * TODO(bankima-docs): مسیرها و نام فیلدها را پس از دریافت مستندات پرتال شریک
 * بانکیما جایگزین کنید. تا آن زمان همین قرارداد پولاد پایدار است.
 */
const axios = require("axios");

const PATHS = {
  token: process.env.BANKIMA_TOKEN_PATH || "/oauth/token", // TODO(bankima-docs)
  verifyTransaction: "/v1/payments/inquiry", // TODO(bankima-docs)
  accountStatement: "/v1/accounts/{accountId}/statement", // TODO(bankima-docs)
  installmentInfo: "/v1/loans/{loanId}/installments", // TODO(bankima-docs)
  paymentLink: "/v1/payments/links", // TODO(bankima-docs)
  balance: "/v1/accounts/{accountId}/balance", // TODO(bankima-docs)
  paya: "/v1/payments/paya", // TODO(bankima-docs)
  satna: "/v1/payments/satna", // TODO(bankima-docs)
  pol: "/v1/payments/pol", // TODO(bankima-docs)
};

function interpolate(path, params) {
  let out = path;
  for (const [k, v] of Object.entries(params || {})) {
    out = out.replace(`{${k}}`, encodeURIComponent(v));
  }
  return out;
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function isRetryable(err) {
  const status = err.response?.status;
  if (!status) return true;
  return status >= 500 || status === 429;
}

async function withRetry(fn, attempts = 3) {
  let last;
  for (let i = 1; i <= attempts; i++) {
    try {
      return await fn();
    } catch (err) {
      last = err;
      if (!isRetryable(err) || i === attempts) throw err;
      await sleep(300 * (2 ** (i - 1)));
    }
  }
  throw last;
}

let cachedToken = { value: null, exp: 0 };

async function getToken() {
  const base = process.env.BANKIMA_BASE_URL;
  const id = process.env.BANKIMA_CLIENT_ID;
  const secret = process.env.BANKIMA_CLIENT_SECRET;
  if (!base || !secret) return null;
  if (cachedToken.value && Date.now() < cachedToken.exp) return cachedToken.value;
  // TODO(bankima-docs): grant_type و نام فیلد توکن را با OAuth رسمی تطبیق دهید.
  const res = await withRetry(() => axios.post(`${base}${PATHS.token}`, {
    grant_type: "client_credentials",
    client_id: id,
    client_secret: secret,
  }, { timeout: 15000 }));
  const token = res.data.access_token || res.data.token;
  const ttl = Number(res.data.expires_in || 600) * 1000;
  cachedToken = { value: token, exp: Date.now() + ttl - 15000 };
  return token;
}

function configured() {
  return Boolean(process.env.BANKIMA_BASE_URL && process.env.BANKIMA_CLIENT_SECRET);
}

async function request(method, path, { params, data } = {}) {
  const base = process.env.BANKIMA_BASE_URL;
  const token = await getToken();
  if (!base || !token) {
    const err = new Error("بانکیما پیکربندی نشده است");
    err.code = "unconfigured";
    throw err;
  }
  return withRetry(() => axios({
    method,
    url: `${base}${path}`,
    params,
    data,
    timeout: 20000,
    headers: { Authorization: `Bearer ${token}` },
  }));
}

async function verifyTransaction(receiptCode) {
  const res = await request("get", PATHS.verifyTransaction, { params: { receiptCode } });
  return res.data;
}

async function getAccountStatement(accountId, from, to) {
  const path = interpolate(PATHS.accountStatement, { accountId });
  const res = await request("get", path, { params: { from, to } });
  return res.data;
}

async function getInstallmentInfo(loanId) {
  const path = interpolate(PATHS.installmentInfo, { loanId });
  const res = await request("get", path);
  return res.data;
}

async function createPaymentLink(memberId, amountToman) {
  const res = await request("post", PATHS.paymentLink, {
    data: { memberId, amountRial: amountToman * 10 },
  });
  return res.data;
}

async function getBalance(accountId) {
  const path = interpolate(PATHS.balance, { accountId });
  const res = await request("get", path);
  return res.data;
}

async function transfer({ rail, destinationIban, amountToman, description, trackId }) {
  const path = rail === "satna" ? PATHS.satna : rail === "pol" ? PATHS.pol : PATHS.paya;
  const res = await request("post", path, {
    data: {
      destinationIban,
      amountRial: amountToman * 10,
      description,
      trackId,
    },
  });
  return res.data;
}

module.exports = {
  PATHS,
  configured,
  verifyTransaction,
  getAccountStatement,
  getInstallmentInfo,
  createPaymentLink,
  getBalance,
  transfer,
};
