import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import {Compra} from './Compra';
import {Producto} from "./Producto";

admin.initializeApp(functions.config().firebase);
const fs = admin.firestore();
const fcm = admin.messaging();
exports.nuevoClienteAgregado = functions.firestore.document('Pedidos/{pedidoId}/Clientes/{clienteId}').onCreate(async (snapshot) => {
    const cliente = snapshot.data();
    const fechaEn = cliente.FechaEntrega.toDate();
    console.log(cliente.FechaEntrega.toDate().getDate())
    const dispositivosQuerySnapshot = await fs.collection('Dispositivos').get();
    const tokens = dispositivosQuerySnapshot.docs.map(snap => snap.id);
    const payload = {
        notification: {
            title: `!Nuevo Cliente agregado!`,
            body: `Se ha agregado el cliente ${cliente.NombreCliente} al pedido con fecha ${fechaEn.getDate()}-${fechaEn.getMonth() + 1}-${fechaEn.getFullYear()}.`,
            clickAction: 'FLUTTER_NOTIFICATION_CLICK'
        }
    };
    return fcm.sendToDevice(tokens, payload);
});

exports.pedidoModificado = functions.firestore.document('Pedidos/{pedidoId}/Clientes/{clienteId}').onUpdate(async (snapshot) => {

    let payload = {};
    const clienteAntes = snapshot.before.data();
    const clienteDespues = snapshot.after.data();
    let comprasAntes: Compra[] = clienteAntes.Compras;
    const comprasDespues: Compra[] = clienteDespues.Compras;
    const dispositivosQuerySnapshot = await fs.collection('Dispositivos').get();
    const clientesQuerySnapshot = await fs.collection(snapshot.after.ref.parent.path).get();
    const clientes = clientesQuerySnapshot.docs.map(snap => snap.data());
    const tokens = dispositivosQuerySnapshot.docs.map(snap => snap.id);
    const cliente = snapshot.after.data();
    const fechaEn = cliente.FechaEntrega.toDate();

    let totalPagoPorPedido = 0;
    const cantidadClientesPorPedido = clientes.length;
    let totalProductosPorPedido = 0;
    let totalGanancias = 0;
    const inventario: Producto[] = [];

    await fs.collection("Inventario").get().then(async snap => {
        snap.forEach(doc => {
            const producto: Producto = {
                ID: doc.data()["ID"].toString(),
                Imagen: doc.data()["Imagen"].toString(),
                PrecioCompra: doc.data()["PrecioCompra"],
                PrecioVenta: doc.data()["PrecioVenta"]
            };
            inventario.push(producto);
        });

        clientes.forEach(clientee => {
            clientee.Compras.forEach((compraa: Compra) => {
                totalPagoPorPedido += inventario.filter((productoo) => compraa.Producto === productoo.ID)[0].PrecioCompra * compraa.Cantidad
            });
            totalProductosPorPedido += clientee.CantidadProductos
            totalGanancias += clientee.Ganancias
        });

        await snapshot.after.ref.parent.parent!.update({
            'TotalPago': totalPagoPorPedido,
            'CantidadClientes': cantidadClientesPorPedido,
            'TotalProductos': totalProductosPorPedido,
            'TotalGanancias': totalGanancias
        }).then((res) => {
            console.log(`!Pedido ${fechaEn.getDate()}-${fechaEn.getMonth() + 1}-${fechaEn.getFullYear()} Actualizado!`);
        }).catch(erro => {
            console.log(erro);
        });

    }).catch(err => {
        console.log('Error getting documents', err);
    });

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
        for (const compra of comprasAntes) {
            const index = comprasAntes.indexOf(compra);
            if (compra.Cantidad !== comprasDespues[index].Cantidad) {
                payload = {
                    notification: {
                        title: `!Pedido ${fechaEn.getDate()}-${fechaEn.getMonth() + 1}-${fechaEn.getFullYear()} Modificado!`,
                        body: `Se ha modificado la cantidad del producto ${compra.Producto} para el pedido de ${cliente.NombreCliente}.`,
                        clickAction: 'FLUTTER_NOTIFICATION_CLICK'
                    }
                };
            }
        }
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
    }

    return fcm.sendToDevice(tokens, payload);
});

exports.nuevoPedidoAgregado = functions.firestore.document('Pedidos/{pedidoId}').onCreate(async (snapshot) => {
    const pedido = snapshot.data();
    const dispositivosQuerySnapshot = await fs.collection('Dispositivos').get();
    const tokens = dispositivosQuerySnapshot.docs.map(snap => snap.id);
    const payload = {
        notification: {
            title: `!Nuevo Pedido agregado!`,
            body: `Se ha abierto un nuevo pedido con fecha ${pedido.ID}`,
            clickAction: 'FLUTTER_NOTIFICATION_CLICK'
        }
    };
    return fcm.sendToDevice(tokens, payload);
});

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
// export const helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
