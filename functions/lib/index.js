"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const functions = require("firebase-functions");
// import * as firebaseCredentials from '../serviceAccountKey.json';
const admin = require("firebase-admin");
// import { Producto } from './Producto';
admin.initializeApp(functions.config().firebase);
const fs = admin.firestore();
const fcm = admin.messaging();
exports.nuevoClienteAgregado = functions.firestore.document('Pedidos/{pedidoId}/Clientes/{clienteId}').onCreate(async (snapshot) => {
    const cliente = snapshot.data();
    const fechaEn = cliente.FechaEntrega.toDate();
    console.log(cliente.FechaEntrega.toDate().getDate());
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
    let comprasAntes = clienteAntes.Compras;
    const comprasDespues = clienteDespues.Compras;
    const dispositivosQuerySnapshot = await fs.collection('Dispositivos').get();
    // const inventarioQuerySnapshot = await fs.collection('Inventario').get();
    const clientesQuerySnapshot = await fs.collection(snapshot.after.ref.parent.path).get();
    const clientes = clientesQuerySnapshot.docs.map(snap => snap.data());
    // const inventario = inventarioQuerySnapshot.docs.map((snap) => snap.data());
    const tokens = dispositivosQuerySnapshot.docs.map(snap => snap.id);
    const cliente = snapshot.after.data();
    const fechaEn = cliente.FechaEntrega.toDate();
    let totalPagoPorPedido = 0;
    const cantidadClientesPorPedido = clientes.length;
    let totalProductosPorPedido = 0;
    let totalGanancias = 0;
    clientes.forEach(clientee => {
        totalPagoPorPedido += clientee.TotalPago;
        totalProductosPorPedido += clientee.CantidadProductos;
        totalGanancias += clientee.Ganancias;
    });
    await snapshot.after.ref.parent.parent.update({
        'TotalPago': totalPagoPorPedido,
        'CantidadClientes': cantidadClientesPorPedido,
        'TotalProductos': totalProductosPorPedido,
        'TotalGanancias': totalGanancias
    }).then((res) => {
        console.log(`!Pedido ${fechaEn.getDate()}-${fechaEn.getMonth() + 1}-${fechaEn.getFullYear()} Actualizado!`);
    }).catch(erro => {
        console.log(erro);
    });
    if (comprasDespues.length < comprasAntes.length) {
        /*let totalPago = 0;
        let cantidadProductos = 0;
        await snapshot.after.ref.update({
            'TotalPago': totalPago,
            'CantidadProductos': cantidadProductos
        }).then(async documento => {
            console.log(`Se han actualizado los datos del pedido ${fechaEn.getDate()}-${fechaEn.getMonth() + 1}-${fechaEn.getFullYear()} para el cliente ${snapshot.after.data()!.NombreCliente}`);
        }).catch(er => {
            console.log(er);
        });*/
        payload = {
            notification: {
                title: `!Pedido ${fechaEn.getDate()}-${fechaEn.getMonth() + 1}-${fechaEn.getFullYear()} Modificado!`,
                body: `Se ha eliminado un producto del pedido para ${cliente.NombreCliente}.`,
                clickAction: 'FLUTTER_NOTIFICATION_CLICK'
            }
        };
    }
    else if (comprasAntes.length < comprasDespues.length) {
        /*let totalPago = 0;
        let cantidadProductos = 0;
        comprasDespues.forEach(async (compra: Compra) => {
            inventario.forEach(producto => {
                if (producto.ID === compra.Producto) {
                    totalPago += compra.Cantidad * producto.Precio;
                }
            });
            cantidadProductos += compra.Cantidad;
        });
        await snapshot.after.ref.update({
            'TotalPago': totalPago,
            'CantidadProductos': cantidadProductos
        }).then(async documento => {
            console.log(`Se han actualizado los datos del pedido ${fechaEn.getDate()}-${fechaEn.getMonth() + 1}-${fechaEn.getFullYear()} para el cliente ${snapshot.before.data()!.NombreCliente}`);
        }).catch(er => {
            console.log(er);
        });*/
        payload = {
            notification: {
                title: `!Pedido ${fechaEn.getDate()}-${fechaEn.getMonth() + 1}-${fechaEn.getFullYear()} Modificado!`,
                body: `Se ha agregado un producto al pedido para ${cliente.NombreCliente}.`,
                clickAction: 'FLUTTER_NOTIFICATION_CLICK'
            }
        };
    }
    if (comprasAntes.length === comprasDespues.length) {
        comprasAntes.forEach(async (compra, index) => {
            if (compra.Cantidad !== comprasDespues[index].Cantidad) {
                /*let totalPago = 0;
                let cantidadProductos = 0;
                comprasDespues.forEach(async (compraa: Compra) => {
                    inventario.forEach(producto => {
                        if (producto.ID === compraa.Producto) {
                            totalPago += compraa.Cantidad * producto.Precio;
                        }
                    });
                    cantidadProductos += compraa.Cantidad;
                });
                await snapshot.before.ref.update({
                    'TotalPago': totalPago,
                    'CantidadProductos': cantidadProductos
                }).then(documento => {
                    console.log(`Se han actualizado los datos del pedido ${fechaEn.getDate()}-${fechaEn.getMonth() + 1}-${fechaEn.getFullYear()} para el cliente ${snapshot.before.data()!.NombreCliente}`);
                }).catch(er => {
                    console.log(er);
                });*/
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
    }
    else if (clienteAntes.CantidadProductos !== clienteDespues.CantidadProductos) {
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
//# sourceMappingURL=index.js.map