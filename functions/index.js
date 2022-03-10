const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp()

exports.reset = functions.region("asia-northeast1").pubsub.schedule('00***')
    .onRun(async () => {
        const firestore = admin.firestore();
        const usersCollection = await firestore.collection('userProfiles').get();
        usersCollection.forEach(async userDoc => {
            const userDocData = userDoc.data();
            const userDocId = userDoc.id;
            const newUserDocData = {　todayThanks: 0　};
            await usersRef.doc(userDocId).update(newUserDocData);
        });
        return;
    });