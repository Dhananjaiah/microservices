#!/bin/bash
# Seed initial data into FoodCart database

set -e

echo "🌱 Seeding FoodCart database..."

# Wait for postgres to be ready
echo "Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres -n foodcart --timeout=120s

# Create menu items table and insert sample data
kubectl exec -i postgres-0 -n foodcart -- psql -U foodcart -d foodcart << 'EOF'
-- Create tables
CREATE TABLE IF NOT EXISTS menu_items (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    category VARCHAR(50),
    available BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100),
    items JSONB,
    total_amount DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS payments (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id),
    amount DECIMAL(10,2),
    payment_method VARCHAR(50),
    status VARCHAR(20) DEFAULT 'pending',
    transaction_id VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample menu items
INSERT INTO menu_items (name, description, price, category) VALUES
    ('Margherita Pizza', 'Classic pizza with tomato, mozzarella, and basil', 12.99, 'pizza'),
    ('Pepperoni Pizza', 'Pizza topped with pepperoni and cheese', 14.99, 'pizza'),
    ('Chicken Burger', 'Grilled chicken burger with lettuce and tomato', 9.99, 'burgers'),
    ('Veggie Burger', 'Plant-based burger with fresh vegetables', 8.99, 'burgers'),
    ('Caesar Salad', 'Fresh romaine lettuce with Caesar dressing', 7.99, 'salads'),
    ('Greek Salad', 'Mixed greens with feta, olives, and cucumber', 8.99, 'salads'),
    ('French Fries', 'Crispy golden fries', 3.99, 'sides'),
    ('Onion Rings', 'Breaded and fried onion rings', 4.99, 'sides'),
    ('Coca Cola', 'Classic Coca Cola', 2.49, 'beverages'),
    ('Lemonade', 'Fresh squeezed lemonade', 2.99, 'beverages')
ON CONFLICT DO NOTHING;

-- Insert sample orders
INSERT INTO orders (customer_name, items, total_amount, status) VALUES
    ('John Doe', '[{"item": "Margherita Pizza", "quantity": 1}, {"item": "Coca Cola", "quantity": 1}]', 15.48, 'completed'),
    ('Jane Smith', '[{"item": "Chicken Burger", "quantity": 2}, {"item": "French Fries", "quantity": 2}]', 27.96, 'completed')
ON CONFLICT DO NOTHING;

-- Show results
SELECT COUNT(*) as menu_items FROM menu_items;
SELECT COUNT(*) as orders FROM orders;
SELECT COUNT(*) as payments FROM payments;

EOF

echo ""
echo "✅ Database seeded successfully!"
echo ""
echo "📊 Verify data:"
echo "  kubectl exec -it postgres-0 -n foodcart -- psql -U foodcart -d foodcart -c 'SELECT name, price, category FROM menu_items;'"
echo ""
