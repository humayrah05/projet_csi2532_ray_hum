-- Hotel Chain Table
CREATE TABLE Hotel_Chain (
    name VARCHAR(100) PRIMARY KEY,
    address_of_central_office VARCHAR(255) NOT NULL,
    number_of_hotels INT DEFAULT 0 
);

-- Archive Table (For historical persistence)
CREATE TABLE Archive (
    archive_ID SERIAL PRIMARY KEY
);

-- Customer Table
CREATE TABLE Customer (
    customer_SIN CHAR(9) PRIMARY KEY, 
    full_name VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    type_of_ID VARCHAR(50) CHECK (type_of_ID IN ('SSN', 'SIN', 'driving license')), 
    registration_date DATE DEFAULT CURRENT_DATE

);

-- Employee Table
CREATE TABLE Employee (
    employee_SIN CHAR(9) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    role_title VARCHAR(100),
    role_salary NUMERIC(10, 2) CHECK (role_salary >= 0),

);

-- Hotel Table
CREATE TABLE Hotel (
    hotel_ID SERIAL PRIMARY KEY,
    chain_name VARCHAR(100) REFERENCES Hotel_Chain(name) ON DELETE CASCADE,
    address VARCHAR(255) NOT NULL,
    number_of_rooms INT DEFAULT 0,
    rating INT CHECK (rating BETWEEN 1 AND 5) 
);

-- Room Table
CREATE TABLE Room (
    room_number INT,
    -- hotel_ID INT REFERENCES Hotel(hotel_ID) ON DELETE CASCADE,
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0), 
    capacity TEXT, 
    amenities TEXT,
    damage TEXT, 
    view VARCHAR(50),
    extension BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (room_number, hotel_ID)
);

-- Contact Tables using Composite Primary Keys 
CREATE TABLE Chain_Email (
    name VARCHAR(100) REFERENCES Hotel_Chain(name) ON DELETE CASCADE,
    email VARCHAR(100),
    PRIMARY KEY (name, email)
);

CREATE TABLE Chain_Phone (
    name VARCHAR(100) REFERENCES Hotel_Chain(name) ON DELETE CASCADE,
    phone_number VARCHAR(20),
    PRIMARY KEY (name, phone_number)
);

CREATE TABLE Hotel_Email (
    hotel_ID INT REFERENCES Hotel(hotel_ID) ON DELETE CASCADE,
    email VARCHAR(100),
    PRIMARY KEY (hotel_ID, email)
);

CREATE TABLE Hotel_Phone (
    hotel_ID INT REFERENCES Hotel(hotel_ID) ON DELETE CASCADE,
    phone_number VARCHAR(20),
    PRIMARY KEY (hotel_ID, phone_number) 
);

-- Employment Roles
CREATE TABLE WorksFor (
    employee_SIN CHAR(9) REFERENCES Employee(employee_SIN),
    hotel_ID INT REFERENCES Hotel(hotel_ID),
    PRIMARY KEY (employee_SIN, hotel_ID)
);

-- Management Rule: Exactly one manager per hotel 
CREATE TABLE Manages (
    hotel_ID INT PRIMARY KEY REFERENCES Hotel(hotel_ID), 
    employee_SIN CHAR(9) REFERENCES Employee(employee_SIN)
);

-- Booking and Renting 
CREATE TABLE Booking (
    booking_number SERIAL PRIMARY KEY,
    room_number INT,
    hotel_ID INT,
    customer_SIN CHAR(9) REFERENCES Customer(customer_SIN),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL CHECK (end_date > start_date),
    FOREIGN KEY (room_number, hotel_ID) REFERENCES Room(room_number, hotel_ID) 
);

CREATE TABLE Renting (
    renting_number SERIAL PRIMARY KEY,
    booking_number INT REFERENCES Booking(booking_number),
    room_number INT,
    hotel_ID INT,
    customer_SIN CHAR(9) REFERENCES Customer(customer_SIN),
    employee_SIN CHAR(9) REFERENCES Employee(employee_SIN),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL CHECK (end_date > start_date),
    FOREIGN KEY (room_number, hotel_ID) REFERENCES Room(room_number, hotel_ID) 
);

-- Archive Links 
CREATE TABLE BookingContains (
    archive_ID INT REFERENCES Archive(archive_ID),
    booking_number INT REFERENCES Booking(booking_number),
    PRIMARY KEY (archive_ID, booking_number)
);

CREATE TABLE RentingContains (
    archive_ID INT REFERENCES Archive(archive_ID),
    renting_number INT REFERENCES Renting(renting_number),
    PRIMARY KEY (archive_ID, renting_number) 
);

-- Explicitly manages the link between a Chain and its Hotels
CREATE TABLE HotelChainHas (
    name VARCHAR(100) REFERENCES Hotel_Chain(name) ON DELETE CASCADE,
    hotel_ID INT REFERENCES Hotel(hotel_ID) ON DELETE CASCADE,
    PRIMARY KEY (name, hotel_ID)
);

-- Explicitly manages the link between a Hotel and its Rooms
CREATE TABLE HotelContains (
    hotel_ID INT REFERENCES Hotel(hotel_ID) ON DELETE CASCADE,
    room_number INT,
    PRIMARY KEY (hotel_ID, room_number),
    FOREIGN KEY (hotel_ID, room_number) REFERENCES Room(hotel_ID, room_number) ON DELETE CASCADE
);

-- Tracking customer search history
CREATE TABLE SearchesFor (
    customer_SIN CHAR(9) REFERENCES Customer(customer_SIN),
    room_number INT,
    hotel_ID INT,
    PRIMARY KEY (customer_SIN, room_number, hotel_ID),
    FOREIGN KEY (room_number, hotel_ID) REFERENCES Room(room_number, hotel_ID)
);

-- Linking customers to their specific bookings
CREATE TABLE CustomerReserves (
    customer_SIN CHAR(9) REFERENCES Customer(customer_SIN),
    room_number INT,
    hotel_ID INT,
    booking_number INT REFERENCES Booking(booking_number),
    PRIMARY KEY (customer_SIN, booking_number),
    FOREIGN KEY (room_number, hotel_ID) REFERENCES Room(room_number, hotel_ID)
);

-- Adding a constraint to ensure valid-looking emails
ALTER TABLE hotel_email 
ADD CONSTRAINT check_email_format CHECK (email LIKE '%@%.%');

-- ALTER TABLE Room
ADD CONSTRAINT check_capacity
CHECK (capacity IN ('Simple','Double','Triple','King','Queen'));

-- Vues
-- Vue 1 : Disponibilité par Hôtel

CREATE OR REPLACE VIEW View_Available_Rooms_Count AS
SELECT 
    h.hotel_id, 
    h.address, 
    h.chain_name,
    COUNT(hc.room_number) AS rooms_free
FROM Hotel h
JOIN HotelContains hc ON h.hotel_id = hc.hotel_id
WHERE NOT EXISTS (
    -- Subquery to check if the room is currently booked
    SELECT 1 
    FROM Booking b 
    WHERE b.room_number = hc.room_number 
      AND b.hotel_id = hc.hotel_id
      AND CURRENT_DATE BETWEEN b.start_date AND b.end_date
)
AND NOT EXISTS (
    -- Subquery to check if the room is currently rented (checked-in)
    SELECT 1 
    FROM Renting r 
    WHERE r.room_number = hc.room_number 
      AND r.hotel_id = hc.hotel_id
      AND CURRENT_DATE BETWEEN r.start_date AND r.end_date
)
GROUP BY h.hotel_id, h.address, h.chain_name;

-- Vue 2 : Rapport des Réservations Actives

CREATE OR REPLACE VIEW View_Active_Bookings AS
SELECT 
    b.booking_number, 
    c.full_name AS customer_name, 
    h.address AS hotel_location, 
    b.start_date
FROM Booking b
JOIN Customer c ON b.customer_SIN = c.customer_SIN
JOIN HotelContains hc ON b.room_number = hc.room_number
JOIN Hotel h ON hc.hotel_id = h.hotel_id
WHERE b.end_date >= CURRENT_DATE;

-- Indexation
-- Optimiser la recherche de chambres par prix (très commun)
CREATE INDEX idx_room_price ON Room(price);

-- Optimiser la recherche de clients par nom
CREATE INDEX idx_customer_name ON Customer(full_name);

-- Optimiser les jointures fréquentes entre hôtels et chaînes
CREATE INDEX idx_hotel_chain ON Hotel(chain_name);
