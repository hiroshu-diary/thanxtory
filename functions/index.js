const functions = require('firebase-functions');
const admin = require('firebase-admin');


exports.resetThanks = functions.region('asia-northeast1').pubsub.schedule('0 0 * * *')
    .onRun(async () => {
        admin.initializeApp();
        const firestore = admin.firestore();
        const querySnapshot = await firestore.collection('userProfiles').get(); 
        const querySnapshotDocs = querySnapshot.docs;
        for(const qds of querySnapshotDocs) {
            const userDocId = qds.id;
            await firestore.collection('userProfiles').doc(userDocId).update({todayThanks: 0});
        }
        return;
    });