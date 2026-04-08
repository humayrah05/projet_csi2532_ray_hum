-- =========================================================
-- SCRIPT DE CRÉATION DE LA BASE DE DONNÉES (21 TABLES)
-- =========================================================

-- 1. Tables Indépendantes
CREATE TABLE Archive (
    archive_id SERIAL PRIMARY KEY
);

CREATE TABLE Hotel_Chain (
    name VARCHAR(100) PRIMARY KEY,
    address_of_central_office VARCHAR(255),
    number_of_hotels INT DEFAULT 0
);

-- 2. Tables Principales (Hôtel et Chambre)
CREATE TABLE Hotel (
    hotel_id SERIAL PRIMARY KEY,
    address VARCHAR(255),
    number_of_rooms INT,
    rating INT CHECK (rating >= 1 AND rating <= 5)
);

CREATE TABLE Room (
    room_number SERIAL PRIMARY KEY,
    price NUMERIC(10,2) NOT NULL,
    capacity VARCHAR(50),
    amenities TEXT,
    damage TEXT,
    view VARCHAR(100),
    extension VARCHAR(50)
);

-- 3. Acteurs (Clients et Employés)
CREATE TABLE Customer (
    customer_sin VARCHAR(15) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    type_of_id VARCHAR(50),
    registration_date DATE DEFAULT CURRENT_DATE,
    room_number INT REFERENCES Room(room_number) ON DELETE SET NULL
);

CREATE TABLE Employee (
    employee_sin VARCHAR(15) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    role_title VARCHAR(100),
    role_salary NUMERIC(10,2),
    hotel_id INT REFERENCES Hotel(hotel_id) ON DELETE SET NULL
);

-- 4. Tables de Contacts (Multi-valuées)
CREATE TABLE Chain_Email (
    name VARCHAR(100) REFERENCES Hotel_Chain(name) ON DELETE CASCADE,
    email VARCHAR(100) NOT NULL,
    PRIMARY KEY (name, email)
);

CREATE TABLE Chain_Phone (
    name VARCHAR(100) REFERENCES Hotel_Chain(name) ON DELETE CASCADE,
    phone_number VARCHAR(20) NOT NULL,
    PRIMARY KEY (name, phone_number)
);

CREATE TABLE Hotel_Email (
    hotel_id INT REFERENCES Hotel(hotel_id) ON DELETE CASCADE,
    email VARCHAR(100) NOT NULL,
    PRIMARY KEY (hotel_id, email)
);

CREATE TABLE Hotel_Phone (
    hotel_id INT REFERENCES Hotel(hotel_id) ON DELETE CASCADE,
    phone_number VARCHAR(20) NOT NULL,
    PRIMARY KEY (hotel_id, phone_number)
);

-- 5. Liaisons Structurelles
CREATE TABLE HotelChainHas (
    name VARCHAR(100) REFERENCES Hotel_Chain(name) ON DELETE CASCADE,
    hotel_id INT REFERENCES Hotel(hotel_id) ON DELETE CASCADE,
    PRIMARY KEY (name, hotel_id)
);

CREATE TABLE HotelContains (
    hotel_id INT REFERENCES Hotel(hotel_id) ON DELETE CASCADE,
    room_number INT REFERENCES Room(room_number) ON DELETE CASCADE,
    PRIMARY KEY (hotel_id, room_number)
);

-- 6. Liaisons Employés (RH)
CREATE TABLE WorksFor (
    employee_sin VARCHAR(15) REFERENCES Employee(employee_sin) ON DELETE CASCADE,
    hotel_id INT REFERENCES Hotel(hotel_id) ON DELETE CASCADE,
    PRIMARY KEY (employee_sin, hotel_id)
);

CREATE TABLE Manages (
    hotel_id INT REFERENCES Hotel(hotel_id) ON DELETE CASCADE,
    employee_sin VARCHAR(15) REFERENCES Employee(employee_sin) ON DELETE CASCADE,
    PRIMARY KEY (hotel_id, employee_sin)
);

-- 7. Recherches
CREATE TABLE SearchesFor (
    customer_sin VARCHAR(15) REFERENCES Customer(customer_sin) ON DELETE CASCADE,
    room_number INT REFERENCES Room(room_number) ON DELETE CASCADE,
    PRIMARY KEY (customer_sin, room_number)
);

-- 8. Réservations et Locations (AVEC LES DATES !)
CREATE TABLE Booking (
    booking_number SERIAL PRIMARY KEY,
    room_number INT REFERENCES Room(room_number) ON DELETE CASCADE,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL CHECK (end_date > start_date)
);

CREATE TABLE Renting (
    renting_number SERIAL PRIMARY KEY,
    room_number INT REFERENCES Room(room_number) ON DELETE CASCADE,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL CHECK (end_date > start_date)
);

-- 9. Liaisons de Réservation/Location
CREATE TABLE CustomerReserves (
    customer_sin VARCHAR(15) REFERENCES Customer(customer_sin) ON DELETE CASCADE,
    room_number INT REFERENCES Room(room_number) ON DELETE CASCADE,
    booking_number INT REFERENCES Booking(booking_number) ON DELETE CASCADE,
    PRIMARY KEY (customer_sin, room_number, booking_number)
);

CREATE TABLE RoomHas (
    booking_number INT REFERENCES Booking(booking_number) ON DELETE CASCADE,
    renting_number INT REFERENCES Renting(renting_number) ON DELETE CASCADE,
    PRIMARY KEY (booking_number, renting_number)
);

-- 10. Archives
CREATE TABLE BookingContains (
    archive_id INT REFERENCES Archive(archive_id) ON DELETE CASCADE,
    booking_number INT REFERENCES Booking(booking_number) ON DELETE CASCADE,
    PRIMARY KEY (archive_id, booking_number)
);

CREATE TABLE RentingContains (
    archive_id INT REFERENCES Archive(archive_id) ON DELETE CASCADE,
    renting_number INT REFERENCES Renting(renting_number) ON DELETE CASCADE,
    PRIMARY KEY (archive_id, renting_number)
);