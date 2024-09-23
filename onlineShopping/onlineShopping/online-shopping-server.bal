import ballerina/grpc;
import ballerina/log;

// Define the gRPC service listener
listener grpc:Listener ep = new (9090);

@grpc:ServiceDescriptor {
    descriptor: ROOT_DESCRIPTOR,  // Ensure that this is properly generated
    descMap: getDescriptorMap()   // Ensure that the descriptor map function is generated properly
}
service "OnlineShoppingService" on ep {

    // In-memory store for products, users, and carts
    private map<Product> products = {};
    private map<User> users = {};
    private map<string[]> carts = {};

    // Admin operations
    remote function AddProduct(Product product) returns ProductCode|error {
        self.products[product.sku] = product;
        log:printInfo("Added product: " + product.name);
        return {sku: product.sku};
    }

    remote function CreateUsers(stream<User, grpc:Error?> userStream) returns OperationStatus|error {
        check userStream.forEach(function(User user) {
            self.users[user.user_id] = user;
        });
        log:printInfo("Users created successfully");
        return {success: true, message: "Users created successfully"};
    }

    remote function UpdateProduct(Product product) returns OperationStatus|error {
        if (self.products.hasKey(product.sku)) {
            self.products[product.sku] = product;
            log:printInfo("Product updated: " + product.name);
            return {success: true, message: "Product updated successfully"};
        }
        return {success: false, message: "Product not found"};
    }

    remote function RemoveProduct(ProductCode productCode) returns ProductList|error {
        _ = self.products.remove(productCode.sku);
        Product[] updatedProducts = self.products.values();
        log:printInfo("Removed product with SKU: " + productCode.sku);
        return {products: updatedProducts};
    }

    // Customer operations
    remote function ListAvailableProducts(Empty value) returns ProductList|error {
        Product[] availableProducts = self.products.values().filter(function(Product product) returns boolean {
            return product.status == AVAILABLE;
        });
        log:printInfo("Listed available products.");
        return {products: availableProducts};
    }

    remote function SearchProduct(ProductCode productCode) returns Product|error {
        if (self.products.hasKey(productCode.sku)) {
            log:printInfo("Searched product found with SKU: " + productCode.sku);
            return self.products.get(productCode.sku);
        }
        return error("Product not found");
    }

    remote function AddToCart(CartItem cartItem) returns OperationStatus|error {
        if (!self.users.hasKey(cartItem.user_id)) {
            return {success: false, message: "User not found"};
        }
        if (!self.products.hasKey(cartItem.sku)) {
            return {success: false, message: "Product not found"};
        }
        if (!self.carts.hasKey(cartItem.user_id)) {
            self.carts[cartItem.user_id] = [];
        }
        self.carts.get(cartItem.user_id).push(cartItem.sku);
        log:printInfo("Added product to cart for user: " + cartItem.user_id);
        return {success: true, message: "Product added to cart"};
    }

    remote function PlaceOrder(UserId userId) returns OrderStatus|error {
        if (!self.users.hasKey(userId.user_id)) {
            return error("User not found");
        }
        if (!self.carts.hasKey(userId.user_id) || self.carts.get(userId.user_id).length() == 0) {
            return error("Cart is empty");
        }
        // In a real application, you would process the order here
        string orderId = "ORD-" + userId.user_id + "-" + self.carts.get(userId.user_id).length().toString();
        _ = self.carts.remove(userId.user_id);
        log:printInfo("Order placed for user: " + userId.user_id + " with Order ID: " + orderId);
        return {order_id: orderId, status: "Placed"};
    }
}
