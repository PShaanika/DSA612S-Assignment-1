import ballerina/io;
import ballerina/grpc;
import online_shopping_pb; // Import the generated protobuf package

public function main() returns error? {
    // Create the client
    online_shopping_pb:OnlineShoppingServiceClient ep = check new ("http://localhost:9090");

    // Admin operations: Add product
    online_shopping_pb:AddProductRequest addProductRequest = {
        product: {
            name: "Smartphone",
            description: "Latest model smartphone",
            price: 999.99,
            stock_quantity: 100,
            sku: "PHONE001",
            status: "AVAILABLE"
        }
    };

    online_shopping_pb:AddProductResponse addedProduct = check ep->addProduct(addProductRequest);
    io:println("Added product with SKU: " + addedProduct.sku);

    // Admin operation: Create users via streaming
    online_shopping_pb:User[] users = [
        {user_id: "USR001", name: "John Doe", role: "CUSTOMER"},
        {user_id: "ADM001", name: "Admin User", role: "ADMIN"}
    ];

    // Stream the users to the server
    stream<online_shopping_pb:User, error?> userStream = new;
    foreach var user in users {
        check userStream.send(user);
    }
    check userStream.close();

    // Call the gRPC method for creating users
    online_shopping_pb:CreateUsersResponse createUsersStatus = check ep->createUsers(userStream);
    io:println("Create users status: " + createUsersStatus.message);

    // Admin operation: Update product details
    online_shopping_pb:UpdateProductRequest updateProductRequest = {
        product: {
            name: "Smartphone",
            description: "Latest model smartphone with improved features",
            price: 1099.99,
            stock_quantity: 50,
            sku: "PHONE001",
            status: "AVAILABLE"
        }
    };

    online_shopping_pb:UpdateProductResponse updateProductResponse = check ep->updateProduct(updateProductRequest);
    io:println("Product updated successfully.");

    // Customer operations: List available products
    online_shopping_pb:ListAvailableProductsRequest listRequest = {};
    online_shopping_pb:ListAvailableProductsResponse availableProducts = check ep->listAvailableProducts(listRequest);
    io:println("Available products: " + availableProducts.products.toString());

    // Customer operation: Search for a product
    online_shopping_pb:SearchProductRequest searchRequest = {sku: "PHONE001"};
    online_shopping_pb:SearchProductResponse searchedProduct = check ep->searchProduct(searchRequest);
    if searchedProduct.found {
        io:println("Searched product: " + searchedProduct.product.toString());
    } else {
        io:println("Product not found.");
    }

    // Customer operation: Add product to cart
    online_shopping_pb:AddToCartRequest addToCartRequest = {
        user_id: "USR001",
        sku: "PHONE001"
    };
    online_shopping_pb:AddToCartResponse addToCartResponse = check ep->addToCart(addToCartRequest);
    io:println("Added product to cart.");

    // Customer operation: Place an order
    online_shopping_pb:PlaceOrderRequest placeOrderRequest = {user_id: "USR001"};
    online_shopping_pb:Order orderStatus = check ep->placeOrder(placeOrderRequest);
    io:println("Order placed: " + orderStatus.toString());

    // Admin operation: Remove product from inventory
    online_shopping_pb:RemoveProductRequest removeProductRequest = {sku: "PHONE001"};
    online_shopping_pb:RemoveProductResponse updatedProducts = check ep->removeProduct(removeProductRequest);
    io:println("Updated product list after removal: " + updatedProducts.products.toString());
}
