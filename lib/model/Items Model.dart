class Items {
  String? type;
  List<Custom>? custom;
  Items({this.type, this.custom});

  Items.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    if (json['custom'] != null) {
      custom = [];
      json['custom'].forEach((v) {
        custom!.add(new Custom.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    if (this.custom != null) {
      data['custom'] = this.custom!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Custom {
  String? itemName;
  bool? selected;
  int? quantity;
  String? categoryName;
  AdditionalDetails? additionalDetails;
  List<Custom>? custom;

  Custom(
      {this.itemName,
      this.selected,
      this.quantity,
      this.categoryName,
      this.additionalDetails,
      this.custom});

  Custom.fromJson(Map<String, dynamic> json) {
    itemName = json['itemName'];
    selected = json['selected'];
    quantity = json['quantity'];
    categoryName = json['categoryName'];
    additionalDetails = json['additionalDetails'] != null
        ? new AdditionalDetails.fromJson(json['additionalDetails'])
        : null;
    if (json['custom'] != null) {
      custom = [];
      json['custom'].forEach((v) {
        custom!.add(new Custom.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['itemName'] = this.itemName;
    data['selected'] = this.selected;
    data['quantity'] = this.quantity;
    data['categoryName'] = this.categoryName;
    if (this.additionalDetails != null) {
      data['additionalDetails'] = this.additionalDetails!.toJson();
    }
    if (this.custom != null) {
      data['custom'] = this.custom!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AdditionalDetails {
  String? description;
  Dimensions? dimensions;
  String? image;

  AdditionalDetails({this.description, this.dimensions, this.image});

  AdditionalDetails.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    dimensions = json['dimensions'] != null
        ? new Dimensions.fromJson(json['dimensions'])
        : null;
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = this.description;
    if (this.dimensions != null) {
      data['dimensions'] = this.dimensions!.toJson();
    }
    data['image'] = this.image;
    return data;
  }
}

class Dimensions {
  int? l;
  int? b;
  int? h;
  String? unit;

  Dimensions({this.l, this.b, this.h, this.unit});

  Dimensions.fromJson(Map<String, dynamic> json) {
    l = json['l'];
    b = json['b'];
    h = json['h'];
    unit = json['unit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['l'] = this.l;
    data['b'] = this.b;
    data['h'] = this.h;
    data['unit'] = this.unit;
    return data;
  }
}

class Customm {
  String? itemName;
  bool? selected;
  int? quantity;
  AdditionalDetails? additionalDetails;
  Customm(
      {this.itemName, this.selected, this.quantity, this.additionalDetails});

  Customm.fromJson(Map<String, dynamic> json) {
    itemName = json['itemName'];
    selected = json['selected'];
    quantity = json['quantity'];
    additionalDetails = json['additionalDetails'] != null
        ? new AdditionalDetails.fromJson(json['additionalDetails'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['itemName'] = this.itemName;
    data['selected'] = this.selected;
    data['quantity'] = this.quantity;
    if (this.additionalDetails != null) {
      data['additionalDetails'] = this.additionalDetails!.toJson();
    }
    return data;
  }
}
