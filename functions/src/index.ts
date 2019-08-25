import * as functions from 'firebase-functions';
// import * as firebaseCredentials from '../serviceAccountKey.json';
import * as admin from 'firebase-admin';
import { Compra } from './Compra';

admin.initializeApp(functions.config().firebase);
const fs = admin.firestore();
const fcm = admin.messaging();
exports.nuevoClienteAgregado = functions.firestore.document('Pedidos/{pedidoId}/Clientes/{clienteId}').onCreate(async (snapshot) => {
    const cliente = snapshot.data()!;
    const fechaEn = cliente.FechaEntrega.toDate();
    console.log(cliente.FechaEntrega.toDate().getDate())
    const dispositivosQuerySnapshot = await fs.collection('Dispositivos').get();
    const tokens = dispositivosQuerySnapshot.docs.map(snap => snap.id);
    const payload = {
        notification: {
            title: `!Nuevo Cliente agregado!`,
            body: `Se ha agregado el cliente ${cliente.NombreCliente} al pedido con fecha ${fechaEn.getDate()}-${fechaEn.getMonth() + 1}-${fechaEn.getFullYear()}`,
            clickAction: 'FLUTTER_NOTIFICATION_CLICK'
        }
    };
    return fcm.sendToDevice(tokens, payload);
});

exports.pedidoModificado = functions.firestore.document('Pedidos/{pedidoId}/Clientes/{clienteId}').onUpdate(async (snapshot) => {

    let payload = {};
    const clienteAntes = snapshot.before.data()!;
    const clienteDespues = snapshot.after.data()!;
    let comprasAntes: Compra[] = clienteAntes.Compras!;
    const comprasDespues: Compra[] = clienteDespues.Compras!;
    const dispositivosQuerySnapshot = await fs.collection('Dispositivos').get();
    const tokens = dispositivosQuerySnapshot.docs.map(snap => snap.id);
    const cliente = snapshot.before.data()!;
    const fechaEn = cliente.FechaEntrega.toDate();

    if (comprasDespues.length < comprasAntes.length) {
        payload = {
            notification: {
                title: `!Pedido ${fechaEn.getDate()}-${fechaEn.getMonth() + 1}-${fechaEn.getFullYear()} Modificado!`,
                body: `Se ha eliminado un producto del pedido para ${cliente.NombreCliente}.`,
                clickAction: 'FLUTTER_NOTIFICATION_CLICK'
            }
        };
    } else if (comprasAntes.length < comprasDespues.length) {
        payload = {
            notification: {
                title: `!Pedido ${fechaEn.getDate()}-${fechaEn.getMonth() + 1}-${fechaEn.getFullYear()} Modificado!`,
                body: `Se ha agregado un producto al pedido para ${cliente.NombreCliente}.`,
                clickAction: 'FLUTTER_NOTIFICATION_CLICK'
            }
        };
    }

    if (comprasAntes.length === comprasDespues.length) {
        comprasAntes.forEach((compra: Compra, index) => {
            if (compra.Cantidad !== comprasDespues[index].Cantidad) {
                payload = {
                    notification: {
                        title: `!Pedido ${fechaEn.getDate()}-${fechaEn.getMonth() + 1}-${fechaEn.getFullYear()} Modificado!`,
                        body: `Se ha modificado la cantidad del producto ${compra.Producto} para el pedido de ${cliente.NombreCliente}.`,
                        clickAction: 'FLUTTER_NOTIFICATION_CLICK'
                    }
                };
            }
        });
    }

    comprasAntes = clienteAntes.Compras;
    if (clienteAntes.Descripcion !== clienteDespues.Descripcion) {
        payload = {
            notification: {
                title: `!Pedido ${fechaEn.getDate()}-${fechaEn.getMonth() + 1}-${fechaEn.getFullYear()} Modificado!`,
                body: `Se ha modificado la descripcion del pedido para ${cliente.NombreCliente}.`,
                clickAction: 'FLUTTER_NOTIFICATION_CLICK'
            }
        };
    } else if (clienteAntes.CantidadProductos !== clienteDespues.CantidadProductos) {
        payload = {
            notification: {
                title: `!Pedido ${fechaEn.getDate()}-${fechaEn.getMonth() + 1}-${fechaEn.getFullYear()} Modificado!`,
                body: `Se ha modificado la cantidad de productos del pedido para ${cliente.NombreCliente}.`,
                clickAction: 'FLUTTER_NOTIFICATION_CLICK'
            }
        };
    } /*else if (clienteAntes.FechaEntrega !== clienteDespues.FechaEntrega) {
        payload = {
            notification: {
                title: `!Pedido ${fechaEn.getDate()}-${fechaEn.getMonth() + 1}-${fechaEn.getFullYear()} Modificado!`,
                body: `Se ha modificado la fecha de entrega del pedido para ${cliente.NombreCliente}.`,
                clickAction: 'FLUTTER_NOTIFICATION_CLICK'
            }
        };
    } else {
        payload = {
            notification: {
                title: `!Pedido ${fechaEn.getDate()}-${fechaEn.getMonth() + 1}-${fechaEn.getFullYear()} Modificado!`,
                body: `Se ha modificado el pedido para ${cliente.NombreCliente}.`,
                clickAction: 'FLUTTER_NOTIFICATION_CLICK'
            }
        };
    }*/

    return fcm.sendToDevice(tokens, payload);
});

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
// export const helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
