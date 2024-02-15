import sqlite3
from datetime import datetime
db = sqlite3.connect("AssessmentDB")
cursor = db.cursor()


def get_most_recent_basket(shopper_id, cursor):
    try:
        cursor.execute("""
            SELECT basket_id
            FROM shopper_baskets
            WHERE shopper_id = ?
            AND DATE(basket_created_date_time) = DATE('now')
            ORDER BY basket_created_date_time DESC
            LIMIT 1
        """, (shopper_id,))
        row = cursor.fetchone()
        if row:
            return row[0]
        else:
            return None
    except sqlite3.Error as e:
        print(f"Error occurred while fetching the most recent basket: {str(e)}")
        return None

def display_main_menu():
    print("ORINOCO – SHOPPER MAIN MENU")
    print("1. Display your order history")
    print("2. Add an item to your basket")
    print("3. View your basket")
    print("4. Change the quantity of an item in your basket")
    print("5. Remove an item from your basket")
    print("6. Checkout")
    print("7. Exit\n")


def display_order_history(shopper_id, cursor):
    try:
        # Fetch the order history for the shopper
        cursor.execute("""
            SELECT o.order_id, o.order_date, p.product_description, s.seller_name, op.price, op.quantity, op.ordered_product_status
            FROM shopper_orders o
            JOIN ordered_products op ON o.order_id = op.order_id
            JOIN products p ON op.product_id = p.product_id
            JOIN sellers s ON op.seller_id = s.seller_id
            WHERE o.shopper_id = ?
            ORDER BY o.order_date DESC
        """, (shopper_id,))

        rows = cursor.fetchall()

        if not rows:
            print("No orders placed by this customer.")
        else:
            print(f"Order history for Shopper ID:{shopper_id}\n")
            for row in rows:
                order_id, order_date, product_description, seller_name, price, quantity_ordered, status = row
                print(f"Order ID - {order_id}\tShopper ID - {shopper_id}\tOrder date - {order_date}\tOrder status - {status}")
                print(f"Product: {product_description}\nSeller: {seller_name}\nPrice: £{price}\nQuantity Ordered: {quantity_ordered}\n")

    except sqlite3.Error as e:
        print(f"An error occurred while fetching order history: {str(e)}")


def add_item_to_basket(shopper_id, cursor):

    try:
        # Display a numbered list of product categories
        cursor.execute("SELECT category_id, category_description FROM categories")
        categories = cursor.fetchall()
        print("Product Categories:")
        for i, (category_id, category_description) in enumerate(categories, start=1):
            print(f"{i}. {category_description}")

        # Prompt the user to enter the number of the product category
        selected_category = int(input("Enter the number of the product category you want to choose from: "))
        if selected_category < 1 or selected_category > len(categories):
            print("Invalid category selection.")
            return

        category_id = categories[selected_category - 1][0]

        # Display a numbered list of available products in the selected category
        cursor.execute("SELECT product_id, product_description FROM products WHERE category_id = ?", (category_id,))
        products = cursor.fetchall()
        print("\nAvailable Products in the Selected Category:")
        for i, (product_id, product_description) in enumerate(products, start=1):
            print(f"{i}. {product_description}")

        # Prompt the user to enter the number of the product they want to purchase
        selected_product = int(input("Enter the number of the product you want to purchase: "))
        if selected_product < 1 or selected_product > len(products):
            print("Invalid product selection.")
            return

        product_id = products[selected_product - 1][0]

        # Display a numbered list of sellers and prices for the selected product
        cursor.execute("""
            SELECT ps.seller_id, s.seller_name, ps.price
            FROM product_sellers ps
            JOIN sellers s ON ps.seller_id = s.seller_id
            WHERE ps.product_id = ?
        """, (product_id,))
        sellers = cursor.fetchall()
        print("\nSellers and Prices for the Selected Product:")
        for i, (seller_id, seller_name, price) in enumerate(sellers, start=1):
            print(f"{i}. Seller: {seller_name}, Price: £{price:.2f}")

        # Prompt the user to enter the number of the seller they wish to buy from
        selected_seller = int(input("Enter the number of the seller you wish to buy the product from: "))
        if selected_seller < 1 or selected_seller > len(sellers):
            print("Invalid seller selection.")
            return

        seller_id = sellers[selected_seller - 1][0]

        # Prompt the user to enter the quantity of the selected product they want to order
        while True:
            quantity = int(input("Enter the quantity you want to order: "))
            if quantity <= 0:
                print("The quantity must be greater than 0.")
            else:
                break

        # Get the price of the selected product from the selected supplier
        selected_product_price = sellers[selected_seller - 1][2]

        # Check if there is a current basket
        recent_basket_id = get_most_recent_basket(shopper_id, cursor)
        if not recent_basket_id:
            cursor.execute("INSERT INTO shopper_baskets (shopper_id, basket_created_date_time) VALUES (?, ?)",
                           (shopper_id, datetime.now()))
            recent_basket_id = cursor.lastrowid

        # Insert a new row into the basket_contents table
        cursor.execute("""
            INSERT INTO basket_contents (basket_id, product_id, seller_id, quantity, price)
            VALUES (?, ?, ?, ?, ?)
        """, (recent_basket_id, product_id, seller_id, quantity, selected_product_price))

        # Commit the transaction
        db.commit()

        print("Item added to your basket\n")

    except sqlite3.Error as e:
        db.rollback()
        print(f"An error occurred while adding an item to the basket: {str(e)}")

def view_basket(shopper_id, cursor):
    try:
        # Check if there is a current basket
        recent_basket_id = get_most_recent_basket(shopper_id, cursor)
        if not recent_basket_id:
            print("Your basket is empty.\n")
            return

        # Fetch items from the basket
        cursor.execute("""
            SELECT p.product_description, s.seller_name, bc.quantity, bc.price
            FROM basket_contents bc
            JOIN products p ON bc.product_id = p.product_id
            JOIN sellers s ON bc.seller_id = s.seller_id
            WHERE bc.basket_id = ?
        """, (recent_basket_id,))
        basket_items = cursor.fetchall()

        print("Your Basket:")
        for i, (product_description, seller_name, quantity, price) in enumerate(basket_items, start=1):
            print(f"{i}. Product: {product_description}, Seller: {seller_name}, Quantity: {quantity}, Price: £{price*quantity:.2f}\n")

    except sqlite3.Error as e:
        print(f"An error occurred while viewing your basket: {str(e)}")

def change_item_quantity_in_basket(shopper_id, cursor):
    try:
        # Check if there is a current basket
        recent_basket_id = get_most_recent_basket(shopper_id, cursor)
        if not recent_basket_id:
            print("Your basket is empty.\n")
            return

        # Fetch items from the basket
        cursor.execute("""
            SELECT bc.basket_id, p.product_description, s.seller_name, bc.quantity, bc.price
            FROM basket_contents bc
            JOIN products p ON bc.product_id = p.product_id
            JOIN sellers s ON bc.seller_id = s.seller_id
            WHERE bc.basket_id = ?
        """, (recent_basket_id,))
        basket_items = cursor.fetchall()

        if not basket_items:
            print("Your basket is empty.\n")
            return

        print("Your Basket:")
        for i, (basket_id, product_description, seller_name, quantity, price) in enumerate(basket_items, start=1):
            print(f"{i}. Product: {product_description}, Seller: {seller_name}, Quantity: {quantity}, Price: £{price * quantity:.2f}")

        # Prompt the user to enter the basket item number they want to update
        while True:
            item_to_update = int(input("Enter the basket item number you want to update: "))
            if item_to_update < 1 or item_to_update > len(basket_items):
                print("The basket item number you have entered is invalid.")
            else:
                break

        selected_item = basket_items[item_to_update - 1]

        # Prompt the user to enter the new quantity for the item selected
        while True:
            new_quantity = int(input(f"Enter the new quantity for {selected_item[1]}: "))
            if new_quantity <= 0:
                print("The quantity must be greater than 0.")
            else:
                break

        basket_id = selected_item[0]

        # Update the basket_contents table with the new quantity
        cursor.execute("UPDATE basket_contents SET quantity = ? WHERE basket_id = ?", (new_quantity, basket_id))
        db.commit()

        print("Quantity updated successfully.")
        # Display the current basket with a re-calculated total
        view_basket(shopper_id, cursor)

    except sqlite3.Error as e:
        db.rollback()
        print(f"An error occurred while changing the quantity: {str(e)}")

def remove_item_from_basket(shopper_id, cursor):
    try:
        # Check if there is a current basket
        recent_basket_id = get_most_recent_basket(shopper_id, cursor)
        if not recent_basket_id:
            print("Your basket is empty.\n")
            return

        # Fetch items from the basket
        cursor.execute("""
            SELECT bc.basket_id, p.product_description, s.seller_name, bc.quantity, bc.price
            FROM basket_contents bc
            JOIN products p ON bc.product_id = p.product_id
            JOIN sellers s ON bc.seller_id = s.seller_id
            WHERE bc.basket_id = ?
        """, (recent_basket_id,))
        basket_items = cursor.fetchall()

        if not basket_items:
            print("Your basket is empty.\n")
            return

        print("Your Basket:")
        for i, (basket_id, product_description, seller_name, quantity, price) in enumerate(basket_items, start=1):
            print(f"{i}. Product: {product_description}, Seller: {seller_name}, Quantity: {quantity}, Price: £{price:.2f}")

        # Prompt the user to enter the basket item number they want to remove
        while True:
            item_to_remove = int(input("Enter the basket item number you want to remove: "))
            if item_to_remove < 1 or item_to_remove > len(basket_items):
                print("The basket item number you have entered is invalid.")
            else:
                break

        selected_item = basket_items[item_to_remove - 1]

        # Prompt the user to confirm removal
        confirm_removal = input(f"Do you want to remove {selected_item[3]} units of {selected_item[1]} from your basket? (Yes/No): ").lower()
        if confirm_removal != 'yes':
            print("Item removal canceled.")
            return

        basket_item_id = selected_item[0]

        # Delete the item from the basket_contents table
        cursor.execute("DELETE FROM basket_contents WHERE basket_id = ?", (basket_item_id,))

        # The following line commits the transaction
        db.commit()

        print("Item removed from your basket.")

        # Check if the basket is empty
        cursor.execute("SELECT COUNT(*) FROM basket_contents WHERE basket_id = ?", (recent_basket_id,))
        count = cursor.fetchone()[0]
        if count == 0:
            print("Your basket is empty.")
        else:
            # Display the current basket with a re-calculated total
            view_basket(shopper_id, cursor)
    except sqlite3.Error as e:
        print(f"An error occurred while removing the item: {str(e)}")

def checkout_basket(shopper_id, cursor):
    try:
        # Check if there is a current basket
        recent_basket_id = get_most_recent_basket(shopper_id, cursor)
        if not recent_basket_id:
            print("Your basket is empty.")
            return

        # Display the current basket and the basket total
        view_basket(shopper_id, cursor)

        # Ask the user if they wish to proceed with the checkout
        checkout_confirmation = input("Do you wish to proceed with the checkout? (Yes/No): ").lower()
        if checkout_confirmation != 'yes':
            print("Checkout canceled.")
            return

        # Insert a new row into the shopper_order table with a status of 'Placed' and the current date and time
        order_date = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        cursor.execute("INSERT INTO shopper_orders (shopper_id, order_status, order_date) VALUES (?, 'Placed', ?)",
                       (shopper_id, order_date))
        order_id = cursor.lastrowid

        # Fetch items from the basket
        cursor.execute("""
            SELECT product_id, seller_id, quantity, price
            FROM basket_contents
            WHERE basket_id = ?
        """, (recent_basket_id,))
        basket_items = cursor.fetchall()

        # Insert a new row into the ordered_product table for each item in the basket
        for item in basket_items:
            product_id, seller_id, quantity, price = item
            cursor.execute("""
                INSERT INTO ordered_products (order_id, product_id, seller_id, quantity, price, ordered_product_status)
                VALUES (?, ?, ?, ?, ?, 'Placed')
            """, (order_id, product_id, seller_id, quantity, price))

        # Delete the rows from the shopper_baskets and basket_contents tables for this basket
        cursor.execute("DELETE FROM shopper_baskets WHERE basket_id = ?", (recent_basket_id,))
        cursor.execute("DELETE FROM basket_contents WHERE basket_id = ?", (recent_basket_id,))

        # The following line commits the transaction
        db.commit()

        print("Checkout complete, your order has been placed.")

    except sqlite3.Error as e:
        print(f"An error occurred during checkout: {str(e)}")


def get_valid_shopper_id(cursor):
    while True:
        try:
            shopper_id = int(input("Enter your shopper id: "))
            cursor.execute("SELECT shopper_first_name, shopper_surname FROM shoppers WHERE shopper_id = ?", (shopper_id,))
            shopper_data = cursor.fetchone()
            if shopper_data:
                shopper_first_name, shopper_surname = shopper_data
                print(f"\nWelcome, {shopper_first_name} {shopper_surname}.")
                return shopper_id
            else:
                print("Shopper not found in the database. Please enter a valid shopper id.")
        except ValueError:
            print("Invalid input. Please enter a valid shopper id as an integer.")


def main():
    try:
        db = sqlite3.connect("AssessmentDB")
        cursor = db.cursor()

        # Prompt for a valid shopper_id
        shopper_id = get_valid_shopper_id(cursor)

        # Check for a recent basket
        recent_basket_id = get_most_recent_basket(shopper_id, cursor)
        if recent_basket_id:
            print(f"Using your most recent basket (Number:{recent_basket_id})")

        while True:
            display_main_menu()
            choice = input("Enter your choice (1-7): ")

            if choice == "1":
                display_order_history(shopper_id, cursor)
                pass
            elif choice == "2":
                add_item_to_basket(shopper_id, cursor)
                pass
            elif choice == "3":
                view_basket(shopper_id, cursor)
                pass
            elif choice == "4":
                change_item_quantity_in_basket(shopper_id, cursor)
                pass
            elif choice == "5":
                remove_item_from_basket(shopper_id, cursor)
                pass
            elif choice == "6":
                checkout_basket(shopper_id, cursor)
                pass
            elif choice == "7":
                print("Exiting...")
                break
            else:
                print("Invalid choice. Please select a valid option (1-7).")

    except sqlite3.Error as e:
        print(f"An error occurred: {str(e)}")


if __name__ == "__main__":
    main()

