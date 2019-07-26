import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { DocumentData } from '@google-cloud/firestore';
admin.initializeApp();

const fs = admin.firestore();
const fcm = admin.messaging();

export const nuevoClienteAgregado = functions.firestore.document('Pedidos/{pedidoId}/Clientes/{clienteId}').onCreate(async (snapshot: DocumentData) => {
    // const cliente = snapshot.data();
    const dispositivosQuerySnapshot = await fs.collection('Dispositivos').get();
    const tokens = dispositivosQuerySnapshot.docs.map(snap => snap.id);
    const payload: admin.messaging.MessagingPayload = {
        notification: {
            title: `Nuevo Cliente agregado!`,
            body: `Se ha agregado un nuevo cliente a un pedido`,
            clickAction: 'FLUTTER_NOTIFICATION_CLICK'
        }
    }
    return fcm.sendToDevice(tokens, payload);
});

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
// export const helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
