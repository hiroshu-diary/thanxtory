const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp()

exports.resetNumberFour = functions.region("asia-northeast1").pubsub.schedule('55 11 * * *')
    .onRun(async () => {
        const firestore = admin.firestore();
        const querySnapshot = await firestore.collection('userProfiles').get(); 
        for(const qds of querySnapshotDocs) {
            const userDocId = qds.id;
            await firestore.collection('userProfiles').doc(userDocId).update({todayThanks: 0 });
        }
        return;
    });