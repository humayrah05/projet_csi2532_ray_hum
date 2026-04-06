-- =========================================================
-- 1. INSERTION DES 5 GRANDES CHAÎNES
-- =========================================================
INSERT INTO Hotel_Chain (name, address_of_central_office, number_of_hotels) VALUES
('Marriott', '10400 Fernwood Rd, Bethesda, MD', 8),
('Hilton', '7930 Jones Branch Dr, McLean, VA', 8),
('Hyatt', '150 N Riverside Plaza, Chicago, IL', 8),
('Best Western', '6201 N 24th Pkwy, Phoenix, AZ', 8),
('Fairmont', '100 Wellington St W, Toronto, ON', 8);

-- =========================================================
-- 2. INSERTION DE 40 HÔTELS AVEC DE VRAIES ADRESSES
-- (Incluant 2 hôtels à Ottawa pour valider la consigne du prof)
-- =========================================================
INSERT INTO Hotel (hotel_ID, address, number_of_rooms, rating) VALUES
-- Marriott (Hôtels 1 à 8)
(1, '100 Kent St, Ottawa, ON', 5, 4), -- OTTAWA
(2, '320 Dalhousie St, Ottawa, ON', 5, 3), -- OTTAWA (Même zone validée !)
(3, '1050 De la Gauchetiere St W, Montreal, QC', 5, 4),
(4, '1 Blue Jays Way, Toronto, ON', 5, 5),
(5, '1128 W Hastings St, Vancouver, BC', 5, 4),
(6, '110 9th Ave SE, Calgary, AB', 5, 4),
(7, '1919 Upper Water St, Halifax, NS', 5, 4),
(8, '850 Place d''Youville, Quebec City, QC', 5, 5),
-- Hilton (Hôtels 9 à 16)
(9, '3 Blvd du Casino, Gatineau, QC', 5, 4),
(10, '145 Richmond St W, Toronto, ON', 5, 4),
(11, '1111 W Georgia St, Vancouver, BC', 5, 5),
(12, '900 boul. René-Lévesque E, Montreal, QC', 5, 3),
(13, '40111 Garfield Rd, Clinton Twp, MI', 5, 3),
(14, '53 Broad St, Boston, MA', 5, 4),
(15, '100 W 26th St, New York, NY', 5, 4),
(16, '250 Marquette Ave, Minneapolis, MN', 5, 5),
-- Hyatt (Hôtels 17 à 24)
(17, '370 King St W, Toronto, ON', 5, 4),
(18, '655 Burrard St, Vancouver, BC', 5, 5),
(19, '2815 24th St NE, Calgary, AB', 5, 3),
(20, '1255 Jeanne-Mance St, Montreal, QC', 5, 4),
(21, '151 E Wacker Dr, Chicago, IL', 5, 4),
(22, '1191 1st Ave, Seattle, WA', 5, 5),
(23, '100 E 8th St, Austin, TX', 5, 4),
(24, '3200 E Mariposa Ave, El Segundo, CA', 5, 3),
-- Best Western (Hôtels 25 à 32)
(25, '377 O''Connor St, Ottawa, ON', 5, 3),
(26, '1240 Peel St, Montreal, QC', 5, 3),
(27, '111 Carlton St, Toronto, ON', 5, 3),
(28, '718 Drake St, Vancouver, BC', 5, 3),
(29, '1314 8th St SW, Calgary, AB', 5, 3),
(30, '3200 S Howell Ave, Milwaukee, WI', 5, 3),
(31, '6201 N 24th Pkwy, Phoenix, AZ', 5, 3),
(32, '150 W 48th St, New York, NY', 5, 3),
-- Fairmont (Hôtels 33 à 40)
(33, '1 Rideau St, Ottawa, ON', 5, 5),
(34, '900 W Georgia St, Vancouver, BC', 5, 5),
(35, '100 Front St W, Toronto, ON', 5, 5),
(36, '900 Rene Levesque Blvd W, Montreal, QC', 5, 5),
(37, '133 9th Ave SW, Calgary, AB', 5, 5),
(38, '400 Dallas St, Dallas, TX', 5, 5),
(39, '2 E 61st St, New York, NY', 5, 5),
(40, '2000 4th Ave, Seattle, WA', 5, 5);

-- =========================================================
-- 3. LIAISON DES HÔTELS AUX CHAÎNES (Table HotelChainHas)
-- =========================================================
INSERT INTO HotelChainHas (name, hotel_ID)
SELECT 
    CASE 
        WHEN id <= 8 THEN 'Marriott'
        WHEN id <= 16 THEN 'Hilton'
        WHEN id <= 24 THEN 'Hyatt'
        WHEN id <= 32 THEN 'Best Western'
        ELSE 'Fairmont'
    END, id
FROM generate_series(1, 40) as id;

-- =========================================================
-- 4. CRÉATION DE 200 CHAMBRES (5 par hôtel, IDs Propres)
-- =========================================================
-- ALTER TABLE Room DROP COLUMN hotel_ID CASCADE;

INSERT INTO Room (room_number, price, capacity, amenities, damage, view, extension)
SELECT
    (h.id * 1000) + r.num, -- Crée des ID parfaits: 1001, 1002, 2001, 40005...
    100.00 + (r.num * 25.00), -- Prix entre 125$ et 225$
    CASE r.num WHEN 1 THEN 'Simple' WHEN 2 THEN 'Double' WHEN 3 THEN 'Triple' WHEN 4 THEN 'King' ELSE 'Queen' END,
    'Wifi, TV, Machine à café',
    'Aucun',
    CASE r.num WHEN 1 THEN 'Ville' WHEN 2 THEN 'Mer' WHEN 3 THEN 'Montagne' ELSE 'Cour intérieure' END,
    CASE WHEN r.num = 1 THEN FALSE ELSE TRUE END
FROM generate_series(1, 40) as h(id)
CROSS JOIN generate_series(1, 5) as r(num);

-- Liaison des chambres aux hôtels
INSERT INTO HotelContains (hotel_ID, room_number)
SELECT h.id, (h.id * 1000) + r.num
FROM generate_series(1, 40) as h(id)
CROSS JOIN generate_series(1, 5) as r(num);

-- =========================================================
-- 5. CRÉATION DE 40 gérants + leur 40 receptionistes 
-- =========================================================
INSERT INTO Employee (employee_SIN, full_name, address, role_title, role_salary) VALUES
('111222001', 'Jean Tremblay', '10 Rue Principale, Ottawa', 'Gestionnaire', 65000),
('111222002', 'Marie Gauthier', '15 Rue Albert, Ottawa', 'Gestionnaire', 65000),
('111222003', 'Luc Dubois', '20 Ave Cartier, Montreal', 'Gestionnaire', 65000),
('111222004', 'Sophie Martin', '34 St King, Toronto', 'Gestionnaire', 65000),
('111222005', 'Patrick Roy', '88 Hastings St, Vancouver', 'Gestionnaire', 65000),
('111222006', 'Isabelle Morin', '12 9th Ave, Calgary', 'Gestionnaire', 65000),
('111222007', 'Marc Lavoie', '55 Water St, Halifax', 'Gestionnaire', 65000),
('111222008', 'Julie Pelletier', '11 Place d''Youville, QC', 'Gestionnaire', 65000),
('111222009', 'Simon Lefebvre', '3 Casino Blvd, Gatineau', 'Gestionnaire', 65000),
('111222010', 'Camille Côté', '100 Richmond, Toronto', 'Gestionnaire', 65000),
('111222011', 'Pierre Bouchard', '12 Georgia St, Vancouver', 'Gestionnaire', 65000),
('111222012', 'Valerie Fortin', '15 Rene-Levesque, Montreal', 'Gestionnaire', 65000),
('111222013', 'Alexandre Gagnon', '20 Garfield, MI', 'Gestionnaire', 65000),
('111222014', 'Emilie Ouellet', '30 Broad St, Boston', 'Gestionnaire', 65000),
('111222015', 'Nicolas Girard', '15 26th St, NY', 'Gestionnaire', 65000),
('111222016', 'Chloe Simard', '50 Marquette, MN', 'Gestionnaire', 65000),
('111222017', 'Maxime Caron', '30 King St, Toronto', 'Gestionnaire', 65000),
('111222018', 'Sarah Beaulieu', '22 Burrard, Vancouver', 'Gestionnaire', 65000),
('111222019', 'Mathieu Richard', '40 24th St, Calgary', 'Gestionnaire', 65000),
('111222020', 'Jessica Bergeron', '12 Jeanne-Mance, Montreal', 'Gestionnaire', 65000),
('111222021', 'Kevin Lapointe', '33 Wacker Dr, Chicago', 'Gestionnaire', 65000),
('111222022', 'Laura Desjardins', '10 1st Ave, Seattle', 'Gestionnaire', 65000),
('111222023', 'Thomas Levesque', '15 8th St, Austin', 'Gestionnaire', 65000),
('111222024', 'Catherine Proulx', '80 Mariposa, CA', 'Gestionnaire', 65000),
('111222025', 'Antoine Martel', '15 O''Connor, Ottawa', 'Gestionnaire', 65000),
('111222026', 'Mireille Poulin', '55 Peel St, Montreal', 'Gestionnaire', 65000),
('111222027', 'David Nadeau', '12 Carlton St, Toronto', 'Gestionnaire', 65000),
('111222028', 'Genevieve Leduc', '20 Drake St, Vancouver', 'Gestionnaire', 65000),
('111222029', 'Francois Blais', '45 8th St, Calgary', 'Gestionnaire', 65000),
('111222030', 'Rachel Morin', '12 Howell, WI', 'Gestionnaire', 65000),
('111222031', 'Vincent Leblanc', '10 Pkwy, Phoenix', 'Gestionnaire', 65000),
('111222032', 'Amelie Couture', '15 48th St, NY', 'Gestionnaire', 65000),
('111222033', 'Gabriel Fournier', '1 Rideau St, Ottawa', 'Gestionnaire', 65000),
('111222034', 'Melissa Cloutier', '10 Georgia St, Vancouver', 'Gestionnaire', 65000),
('111222035', 'Jonathan Demers', '5 Front St, Toronto', 'Gestionnaire', 65000),
('111222036', 'Stephanie Beaudoin', '12 Rene Levesque, Montreal', 'Gestionnaire', 65000),
('111222037', 'Guillaume Gosselin', '40 9th Ave, Calgary', 'Gestionnaire', 65000),
('111222038', 'Sabrina Turcotte', '10 Dallas St, TX', 'Gestionnaire', 65000),
('111222039', 'Olivier St-Pierre', '15 61st St, NY', 'Gestionnaire', 65000),
('111222040', 'Vanessa Plante', '20 4th Ave, Seattle', 'Gestionnaire', 65000);


INSERT INTO Manages (hotel_ID, employee_SIN) VALUES
(1, '111222001'), (2, '111222002'), (3, '111222003'), (4, '111222004'), (5, '111222005'),
(6, '111222006'), (7, '111222007'), (8, '111222008'), (9, '111222009'), (10, '111222010'),
(11, '111222011'), (12, '111222012'), (13, '111222013'), (14, '111222014'), (15, '111222015'),
(16, '111222016'), (17, '111222017'), (18, '111222018'), (19, '111222019'), (20, '111222020'),
(21, '111222021'), (22, '111222022'), (23, '111222023'), (24, '111222024'), (25, '111222025'),
(26, '111222026'), (27, '111222027'), (28, '111222028'), (29, '111222029'), (30, '111222030'),
(31, '111222031'), (32, '111222032'), (33, '111222033'), (34, '111222034'), (35, '111222035'),
(36, '111222036'), (37, '111222037'), (38, '111222038'), (39, '111222039'), (40, '111222040');

INSERT INTO WorksFor (employee_SIN, hotel_ID) VALUES
('111222001', 1), ('111222002', 2), ('111222003', 3), ('111222004', 4), ('111222005', 5),
('111222006', 6), ('111222007', 7), ('111222008', 8), ('111222009', 9), ('111222010', 10),
('111222011', 11), ('111222012', 12), ('111222013', 13), ('111222014', 14), ('111222015', 15),
('111222016', 16), ('111222017', 17), ('111222018', 18), ('111222019', 19), ('111222020', 20),
('111222021', 21), ('111222022', 22), ('111222023', 23), ('111222024', 24), ('111222025', 25),
('111222026', 26), ('111222027', 27), ('111222028', 28), ('111222029', 29), ('111222030', 30),
('111222031', 31), ('111222032', 32), ('111222033', 33), ('111222034', 34), ('111222035', 35),
('111222036', 36), ('111222037', 37), ('111222038', 38), ('111222039', 39), ('111222040', 40);


INSERT INTO Employee (employee_SIN, full_name, address, role_title, role_salary) VALUES
('333444001', 'Marc-André Roy', '45 Rue Metcalfe, Ottawa', 'Réceptionniste', 45000),
('333444002', 'Elena Rossi', '200 Rideau St, Ottawa', 'Réceptionniste', 45000),
('333444003', 'Thomas Girard', '500 Rue Sherbrooke, Montreal', 'Réceptionniste', 45000),
('333444004', 'Clara Bennett', '12 Spadina Ave, Toronto', 'Réceptionniste', 45000),
('333444005', 'Yuki Tanaka', '77 Robson St, Vancouver', 'Réceptionniste', 45000),
('333444006', 'David Miller', '101 8th Ave, Calgary', 'Réceptionniste', 45000),
('333444007', 'Sarah O''Neil', '22 Barrington St, Halifax', 'Réceptionniste', 45000),
('333444008', 'Mathieu Dion', '900 Rue Saint-Jean, Québec', 'Réceptionniste', 45000),
('333444009', 'Léa Lefebvre', '55 Boul. Gréber, Gatineau', 'Réceptionniste', 45000),
('333444010', 'James Wilson', '80 Bay St, Toronto', 'Réceptionniste', 45000),
('333444011', 'Sophie Chen', '400 Davie St, Vancouver', 'Réceptionniste', 45000),
('333444012', 'Antoine Mercier', '1200 Rue Peel, Montreal', 'Réceptionniste', 45000),
('333444013', 'Emily Davis', '1500 Woodward Ave, Detroit', 'Réceptionniste', 45000),
('333444014', 'Robert Smith', '10 State St, Boston', 'Réceptionniste', 45000),
('333444015', 'Maria Garcia', '450 7th Ave, New York', 'Réceptionniste', 45000),
('333444016', 'Paul Anderson', '111 Nicollet Mall, Minneapolis', 'Réceptionniste', 45000),
('333444017', 'Oliver Brown', '250 Front St W, Toronto', 'Réceptionniste', 45000),
('333444018', 'Isabella Taylor', '999 Canada Place, Vancouver', 'Réceptionniste', 45000),
('333444019', 'Lucas Martin', '600 4th St SW, Calgary', 'Réceptionniste', 45000),
('333444020', 'Emma Petit', '150 Rue Sainte-Catherine, Montreal', 'Réceptionniste', 45000),
('333444021', 'William Clark', '233 S Wacker Dr, Chicago', 'Réceptionniste', 45000),
('333444022', 'Zoe Walker', '1301 2nd Ave, Seattle', 'Réceptionniste', 45000),
('333444023', 'Noah Scott', '111 Congress Ave, Austin', 'Réceptionniste', 45000),
('333444024', 'Mia Adams', '200 Main St, Los Angeles', 'Réceptionniste', 45000),
('333444025', 'Gabriel Roy', '300 Laurier Ave, Ottawa', 'Réceptionniste', 45000),
('333444026', 'Sandrine Tremblay', '2050 Rue Mansfield, Montreal', 'Réceptionniste', 45000),
('333444027', 'Benjamin Lee', '55 York St, Toronto', 'Réceptionniste', 45000),
('333444028', 'Alyssa Wong', '1011 W Cordova St, Vancouver', 'Réceptionniste', 45000),
('333444029', 'Hugo Bouchard', '700 Centre St S, Calgary', 'Réceptionniste', 45000),
('333444030', 'Ava Wright', '411 E Wisconsin Ave, Milwaukee', 'Réceptionniste', 45000),
('333444031', 'Samuel Green', '2 N Central Ave, Phoenix', 'Réceptionniste', 45000),
('333444032', 'Charlotte King', '1535 Broadway, New York', 'Réceptionniste', 45000),
('333444033', 'Justin Fortin', '2 Elgin St, Ottawa', 'Réceptionniste', 45000),
('333444034', 'Maya Dubois', '1100 Melville St, Vancouver', 'Réceptionniste', 45000),
('333444035', 'Liam Gauthier', '65 Front St W, Toronto', 'Réceptionniste', 45000),
('333444036', 'Alice Morin', '1000 Rue de la Gauchetière, Montreal', 'Réceptionniste', 45000),
('333444037', 'Nathan Lavoie', '200 Barclay Parade SW, Calgary', 'Réceptionniste', 45000),
('333444038', 'Sofia Martinez', '1200 Ross Ave, Dallas', 'Réceptionniste', 45000),
('333444039', 'Arthur Jenkins', '5th Ave & 59th St, New York', 'Réceptionniste', 45000),
('333444040', 'Victoria Fisher', '1400 6th Ave, Seattle', 'Réceptionniste', 45000);

INSERT INTO WorksFor (employee_SIN, hotel_ID) VALUES
('333444001', 1), ('333444002', 2), ('333444003', 3), ('333444004', 4), ('333444005', 5),
('333444006', 6), ('333444007', 7), ('333444008', 8), ('333444009', 9), ('333444010', 10),
('333444011', 11), ('333444012', 12), ('333444013', 13), ('333444014', 14), ('333444015', 15),
('333444016', 16), ('333444017', 17), ('333444018', 18), ('333444019', 19), ('333444020', 20),
('333444021', 21), ('333444022', 22), ('333444023', 23), ('333444024', 24), ('333444025', 25),
('333444026', 26), ('333444027', 27), ('333444028', 28), ('333444029', 29), ('333444030', 30),
('333444031', 31), ('333444032', 32), ('333444033', 33), ('333444034', 34), ('333444035', 35),
('333444036', 36), ('333444037', 37), ('333444038', 38), ('333444039', 39), ('333444040', 40);
