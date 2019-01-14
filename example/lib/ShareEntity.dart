import 'dart:convert';

class ShareEntity{
  final String shareuri;
  final String sharedesc;

  ShareEntity(this.shareuri,this.sharedesc);

  ShareEntity.fromJson(Map<String,dynamic> json)
    :shareuri = json['shareuri'],
      sharedesc = json['sharedesc'];

  Map<String,dynamic> toJson() =>
      {
        'shareuri':shareuri,
        'sharedesc':sharedesc,
      };
}