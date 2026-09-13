import {getFirestore} from "firebase-admin/firestore";
import {getMessaging} from "firebase-admin/messaging";

const db = getFirestore();

/** ارسال پوش به یک عضو. شکست اعلان مسیر مالی را متوقف نمی‌کند. */
export async function sendPushNotification(
  userId: string,
  title: string,
  body: string,
): Promise<void> {
  try {
    const user = (await db.doc(`users/${userId}`).get()).data();
    if (!user?.fcmToken) return;
    await getMessaging().send({
      token: user.fcmToken,
      notification: {title, body},
      android: {priority: "high"},
    });
  } catch {
    // ignore
  }
}
