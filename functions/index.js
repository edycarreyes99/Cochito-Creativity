"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});
const fs = admin.firestore();
const fcm = admin.messaging();
exports.nuevoClienteAgregado = functions.firestore.document('Pedidos/{pedidoId}/Clientes/{clienteId}').onCreate(async (snapshot) => {
    var cliente = snapshot.data();
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
// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
/*export const helloWorld = functions.https.onRequest((request, response) => {
    response.send("Hello from Firebase!");
});*/
//# sourceMappingURL=index.js.map