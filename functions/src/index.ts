import * as functions from 'firebase-functions';
import * as firebaseCredentials from '../serviceAccountKey.json';
import * as admin from 'firebase-admin';

admin.initializeApp({
    credential: admin.credential.cert(firebaseCredentials.default)
});
const fs = admin.firestore();
const fcm = admin.messaging();
exports.nuevoClienteAgregado = functions.firestore.document('Pedidos/{pedidoId}/Clientes/{clienteId}').onCreate(async (snapshot) => {
    let cliente = snapshot.data();
    var fechaEn = cliente.FechaEntrega.toDate();
    console.log(cliente.FechaEntrega.toDate().getDate())
    const dispositivosQuerySnapshot = await fs.collection('Dispositivos').get();
    const tokens = dispositivosQuerySnapshot.docs.map(snap => snap.id);
    const payload = {
        notification: {
            title: `Nuevo Cliente agregado!`,
            body: `Se ha agregado el cliente ${cliente.NombreCliente} al pedido con fecha ${fechaEn.getDate()}-${fechaEn.getMonth() + 1}-${fechaEn.getFullYear()}`,
            clickAction: 'FLUTTER_NOTIFICATION_CLICK'
        }
    };
    return fcm.sendToDevice(tokens, payload);
});

exports.pedidoModificado = functions.firestore.document('Pedidos/{pedidoId}/Clientes/{clienteId}').onUpdate(async (snapshot)=>{
    var clienteAnterior = snapshot.after.data();
    var clienteDespues = snapshot.before.data();
    var fechaEntrega = clienteAnterior.FechaEntrega.toDate();
});

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
// export const helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
