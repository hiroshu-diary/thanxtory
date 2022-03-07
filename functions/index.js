const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp()

exports.resetCount = functions.region("asia-northeast1").pubsub.
    .schedule('00***')
    .onRun(async (context) => {
        let ref = firestore.collection('userProfiles').get;
        lat data = snapshot.data() as Map<String, dynamic>;
        await data.update({'todayThanks': 0});
        return;
    });
//todo 【質問】Cloud Functionsで全ユーザーのtodayThanksを0に更新したい