class Product {
  Map<String, dynamic> data;
  int quantity;

  Product(Map<String, dynamic> data) {
    this.data = data;
    quantity = 1;
  }

  @override
  bool operator ==(other) {
    return other is Product && this.data['id'] == other.data['id'];
  }

  bool isSameAs(Product item) {
    return this.data['id'] == item.data['id'];
  }

  @override
  int get hashCode => this.data['id'].hashCode;
}
