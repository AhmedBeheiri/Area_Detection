class MapsModel {
  final List<Data> data;

  MapsModel({this.data});

  factory MapsModel.fromJson(Map<String, dynamic> json) {
    return MapsModel(
      data: json['data'] != null
          ? (json['data'] as List).map((i) => Data.fromJson(i)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  final int id;
  final String name;

  final String lat;
  final String lng;
  final int osm_id;
  final int parent_id;

  Data({this.id, this.name, this.lat, this.lng, this.osm_id, this.parent_id});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json['id'],
      name: json['name'],
      lat: json['lat'],
      lng: json['lng'],
      osm_id: json['osm_id'] != null ? json['osm_id'] : null,
      parent_id: json['parent_id'] != null ? json['parent_id'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    if (this.osm_id != null) {
      data['osm_id'] = this.osm_id;
    }
    if (this.parent_id != null) {
      data['parent_id'] = this.parent_id;
    }
    return data;
  }
}
