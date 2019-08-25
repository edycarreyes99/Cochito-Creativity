import { Compra } from "./Compra";

export interface DetallesPedido {
    ID: string;
    Descripcion: string;
    LugarEntrega: string;
    NombreCliente: string;
    RedSocial: string;
    FechaEntrega: Date;
    CantidadProducto: number;
    TotalPago: number;
    Compras: Compra[];
}