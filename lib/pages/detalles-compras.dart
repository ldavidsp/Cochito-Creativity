import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import '../classes/Detalle-Pedido.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../classes/Producto.dart';
import 'dart:async';
import '../classes/Detalle-Pedido.dart';

class DetallesComprasPage extends StatefulWidget {
  DetallesComprasPage({this.titulo, this.detallePedido, this.idPedido});

  final String titulo;
  final DetallePedido detallePedido;
  final String idPedido;

  @override
  _DetallesComprasPageState createState() => _DetallesComprasPageState();
}

class _DetallesComprasPageState extends State<DetallesComprasPage> {
  List<Producto> productos;
  Firestore fs = Firestore.instance;
  StreamSubscription<QuerySnapshot> productosSub;
  StreamSubscription<DocumentSnapshot> clienteSub;
  DetallePedido cliente;

  Stream<QuerySnapshot> getListaDeInventario({int offset, int limit}) {
    Stream<QuerySnapshot> snapshots =
        Firestore.instance.collection('/Inventario/').snapshots();

    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }

    if (limit != null) {
      snapshots = snapshots.take(limit);
    }

    return snapshots;
  }

  Stream<DocumentSnapshot> getDetallesDocumento({int offset, int limit}) {
    Stream<DocumentSnapshot> snapshots = Firestore.instance
        .document(
            'Pedidos/${this.widget.idPedido}/Clientes/${this.widget.detallePedido.id}')
        .snapshots();
    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }

    if (limit != null) {
      snapshots = snapshots.take(limit);
    }

    return snapshots;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    this.productos = new List();

    this.productosSub =
        this.getListaDeInventario().listen((QuerySnapshot snapshot) {
      final List<Producto> productoss = snapshot.documents
          .map((documentSnapshot) => Producto.fromMap(documentSnapshot.data))
          .toList();
      setState(() {
        this.productos = productoss;
      });
    });

    this.clienteSub =
        this.getDetallesDocumento().listen((DocumentSnapshot snapshot) {
      final DetallePedido cliente = new DetallePedido.fromMap(snapshot.data);
      setState(() {
        this.cliente = cliente;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          this.widget.titulo,
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => null,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => null,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 30.0, left: 20.0, right: 20.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Total a pagar: C\$' +
                              this.cliente.totalPago.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                        )
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Lugar de entrega:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            this.cliente.lugarEntrega,
                          )
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Red Social:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            this.cliente.redSocial,
                          )
                        ],
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Text(
                              'Cantidad de Productos:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              this.cliente.cantidadProductos.toString(),
                            )
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Text(
                              'Hora de entrega:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              this.cliente.fechaEntrega.hour.toString() +
                                  ":" +
                                  this.cliente.fechaEntrega.minute.toString(),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Descripcion:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          this.cliente.descripcion,
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Text(
                      'Productos:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 200.0,
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: GridView.builder(
                  itemCount: this.cliente.compras.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemBuilder: (BuildContext ctx, int index) {
                    return GestureDetector(
                      onTap: () => print("Objeto Tocado"),
                      child: Container(
                          padding: EdgeInsets.all(3.0),
                          alignment: Alignment.topRight,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(this
                                      .productos
                                      .firstWhere((producto) =>
                                          this
                                              .cliente
                                              .compras[index]
                                              .producto ==
                                          producto.id)
                                      .imagen),
                                  fit: BoxFit.cover)),
                          child: CircleAvatar(
                            child: Text(
                              this
                                  .cliente
                                  .compras[index]
                                  .cantidadProducto
                                  .toString(),
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            backgroundColor: Colors.redAccent[100],
                          ) /*CachedNetworkImage(
                            imageUrl: this
                                .productos
                                .firstWhere((producto) =>
                                    this
                                        .widget
                                        .detallePedido
                                        .compras[index]
                                        .producto ==
                                    producto.id)
                                .imagen,
                            imageBuilder: (context, imageProvider) => Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),*/
                          ),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () => {},
      ),
    );
  }
}
