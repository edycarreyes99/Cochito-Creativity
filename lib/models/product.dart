import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@immutable
@JsonSerializable()
class Product {
  final String? image, title, description, id;
  final double? price, size;
  final bool? status;

  @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)
  final Color? color;

  const Product(
      {@required this.id,
      @required this.image,
      @required this.title,
      @required this.description,
      @required this.price,
      @required this.size,
      @required this.color,
      @required this.status});

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  Map<String, dynamic> toJson() => _$ProductToJson(this);
}

Color? _colorFromJson(String colorString) {
  int? intColor = int.tryParse(colorString, radix: 16);
  if (intColor == null)
    return null;
  else
    return new Color(intColor);
}

String _colorToJson(Color? color) => color!.value.toRadixString(16);
