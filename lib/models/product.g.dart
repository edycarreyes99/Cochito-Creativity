// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) {
  return Product(
    id: json['id'] as String?,
    image: json['image'] as String?,
    title: json['title'] as String?,
    description: json['description'] as String?,
    price: (json['price'] as num?)?.toDouble(),
    size: (json['size'] as num?)?.toDouble(),
    color: _colorFromJson(json['color'] as String),
  );
}

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
      'image': instance.image,
      'title': instance.title,
      'description': instance.description,
      'id': instance.id,
      'price': instance.price,
      'size': instance.size,
      'color': _colorToJson(instance.color),
    };
