/**
 * نقطهٔ ورود Functions: Callableهای JS + تریگر/زمان‌بندی TypeScript.
 */
const {initializeApp} = require("firebase-admin/app");
initializeApp();

Object.assign(exports, require("./src/callables"));
Object.assign(exports, require("./lib/triggers"));
Object.assign(exports, require("./lib/scheduled"));
exports.sendPushNotification = require("./lib/notify").sendPushNotification;
