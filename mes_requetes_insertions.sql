











-- =========================================================
-- 1. INSERTION DES 5 GRANDES CHAÎNES
-- =========================================================
INSERT INTO "Hotel Chain" (name, address_of_central_office, number_of_hotels) VALUES
('Marriott', '10400 Fernwood Rd, Bethesda, MD', 8),
('Hilton', '7930 Jones Branch Dr, McLean, VA', 8),
('Hyatt', '150 N Riverside Plaza, Chicago, IL', 8),
('Best Western', '6201 N 24th Pkwy, Phoenix, AZ', 8),
('Fairmont', '100 Wellington St W, Toronto, ON', 8);

-- =========================================================
-- 2. INSERTION DE 40 HÔTELS AVEC DE VRAIES ADRESSES
-- (Incluant 2 hôtels à Ottawa pour valider la consigne du prof)
-- =========================================================
INSERT INTO "Hotel" (hotel_ID, address, number_of_rooms, rating) VALUES
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
INSERT INTO "HotelChainHas" (name, hotel_ID)
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
INSERT INTO "Room" (room_number, price, capacity, amenities, damage, view, extension)
SELECT
    (h.id * 1000) + r.num, -- Crée des ID parfaits: 1001, 1002, 2001, 40005...
    100.00 + (r.num * 25.00), -- Prix entre 125$ et 225$
    CASE r.num WHEN 1 THEN 'Simple' WHEN 2 THEN 'Double' WHEN 3 THEN 'Triple' WHEN 4 THEN 'King' ELSE 'Queen' END,
    'Wifi, TV, Machine à café',
    'Aucun',
    CASE r.num WHEN 1 THEN 'Ville' WHEN 2 THEN 'Mer' WHEN 3 THEN 'Montagne' ELSE 'Cour intérieure' END,
    CASE WHEN r.num = 1 THEN 'Non' ELSE 'Oui' END
FROM generate_series(1, 40) as h(id)
CROSS JOIN generate_series(1, 5) as r(num);

-- Liaison des chambres aux hôtels
INSERT INTO "HotelContains" (hotel_ID, room_number)
SELECT h.id, (h.id * 1000) + r.num
FROM generate_series(1, 40) as h(id)
CROSS JOIN generate_series(1, 5) as r(num);

-- =========================================================
-- 5. CRÉATION DE 40 gérants + leur 40 receptionistes 
-- =========================================================
INSERT INTO "Employee" (employee_SIN, full_name, address, role_title, role_salary, hotel_id) VALUES
('111-222-001', 'Jean Tremblay', '10 Rue Principale, Ottawa', 'Gestionnaire', 65000, 1),
('111-222-002', 'Marie Gauthier', '15 Rue Albert, Ottawa', 'Gestionnaire', 65000, 2),
('111-222-003', 'Luc Dubois', '20 Ave Cartier, Montreal', 'Gestionnaire', 65000, 3),
('111-222-004', 'Sophie Martin', '34 St King, Toronto', 'Gestionnaire', 65000, 4),
('111-222-005', 'Patrick Roy', '88 Hastings St, Vancouver', 'Gestionnaire', 65000, 5),
('111-222-006', 'Isabelle Morin', '12 9th Ave, Calgary', 'Gestionnaire', 65000, 6),
('111-222-007', 'Marc Lavoie', '55 Water St, Halifax', 'Gestionnaire', 65000, 7),
('111-222-008', 'Julie Pelletier', '11 Place d''Youville, QC', 'Gestionnaire', 65000, 8),
('111-222-009', 'Simon Lefebvre', '3 Casino Blvd, Gatineau', 'Gestionnaire', 65000, 9),
('111-222-010', 'Camille Côté', '100 Richmond, Toronto', 'Gestionnaire', 65000, 10),
('111-222-011', 'Pierre Bouchard', '12 Georgia St, Vancouver', 'Gestionnaire', 65000, 11),
('111-222-012', 'Valerie Fortin', '15 Rene-Levesque, Montreal', 'Gestionnaire', 65000, 12),
('111-222-013', 'Alexandre Gagnon', '20 Garfield, MI', 'Gestionnaire', 65000, 13),
('111-222-014', 'Emilie Ouellet', '30 Broad St, Boston', 'Gestionnaire', 65000, 14),
('111-222-015', 'Nicolas Girard', '15 26th St, NY', 'Gestionnaire', 65000, 15),
('111-222-016', 'Chloe Simard', '50 Marquette, MN', 'Gestionnaire', 65000, 16),
('111-222-017', 'Maxime Caron', '30 King St, Toronto', 'Gestionnaire', 65000, 17),
('111-222-018', 'Sarah Beaulieu', '22 Burrard, Vancouver', 'Gestionnaire', 65000, 18),
('111-222-019', 'Mathieu Richard', '40 24th St, Calgary', 'Gestionnaire', 65000, 19),
('111-222-020', 'Jessica Bergeron', '12 Jeanne-Mance, Montreal', 'Gestionnaire', 65000, 20),
('111-222-021', 'Kevin Lapointe', '33 Wacker Dr, Chicago', 'Gestionnaire', 65000, 21),
('111-222-022', 'Laura Desjardins', '10 1st Ave, Seattle', 'Gestionnaire', 65000, 22),
('111-222-023', 'Thomas Levesque', '15 8th St, Austin', 'Gestionnaire', 65000, 23),
('111-222-024', 'Catherine Proulx', '80 Mariposa, CA', 'Gestionnaire', 65000, 24),
('111-222-025', 'Antoine Martel', '15 O''Connor, Ottawa', 'Gestionnaire', 65000, 25),
('111-222-026', 'Mireille Poulin', '55 Peel St, Montreal', 'Gestionnaire', 65000, 26),
('111-222-027', 'David Nadeau', '12 Carlton St, Toronto', 'Gestionnaire', 65000, 27),
('111-222-028', 'Genevieve Leduc', '20 Drake St, Vancouver', 'Gestionnaire', 65000, 28),
('111-222-029', 'Francois Blais', '45 8th St, Calgary', 'Gestionnaire', 65000, 29),
('111-222-030', 'Rachel Morin', '12 Howell, WI', 'Gestionnaire', 65000, 30),
('111-222-031', 'Vincent Leblanc', '10 Pkwy, Phoenix', 'Gestionnaire', 65000, 31),
('111-222-032', 'Amelie Couture', '15 48th St, NY', 'Gestionnaire', 65000, 32),
('111-222-033', 'Gabriel Fournier', '1 Rideau St, Ottawa', 'Gestionnaire', 65000, 33),
('111-222-034', 'Melissa Cloutier', '10 Georgia St, Vancouver', 'Gestionnaire', 65000, 34),
('111-222-035', 'Jonathan Demers', '5 Front St, Toronto', 'Gestionnaire', 65000, 35),
('111-222-036', 'Stephanie Beaudoin', '12 Rene Levesque, Montreal', 'Gestionnaire', 65000, 36),
('111-222-037', 'Guillaume Gosselin', '40 9th Ave, Calgary', 'Gestionnaire', 65000, 37),
('111-222-038', 'Sabrina Turcotte', '10 Dallas St, TX', 'Gestionnaire', 65000, 38),
('111-222-039', 'Olivier St-Pierre', '15 61st St, NY', 'Gestionnaire', 65000, 39),
('111-222-040', 'Vanessa Plante', '20 4th Ave, Seattle', 'Gestionnaire', 65000, 40);



INSERT INTO "Employee" (employee_SIN, full_name, address, role_title, role_salary, hotel_id) VALUES
('333-444-001', 'Marc-André Roy', '45 Rue Metcalfe, Ottawa', 'Réceptionniste', 45000, 1),
('333-444-002', 'Elena Rossi', '200 Rideau St, Ottawa', 'Réceptionniste', 45000, 2),
('333-444-003', 'Thomas Girard', '500 Rue Sherbrooke, Montreal', 'Réceptionniste', 45000, 3),
('333-444-004', 'Clara Bennett', '12 Spadina Ave, Toronto', 'Réceptionniste', 45000, 4),
('333-444-005', 'Yuki Tanaka', '77 Robson St, Vancouver', 'Réceptionniste', 45000, 5),
('333-444-006', 'David Miller', '101 8th Ave, Calgary', 'Réceptionniste', 45000, 6),
('333-444-007', 'Sarah O''Neil', '22 Barrington St, Halifax', 'Réceptionniste', 45000, 7),
('333-444-008', 'Mathieu Dion', '900 Rue Saint-Jean, Québec', 'Réceptionniste', 45000, 8),
('333-444-009', 'Léa Lefebvre', '55 Boul. Gréber, Gatineau', 'Réceptionniste', 45000, 9),
('333-444-010', 'James Wilson', '80 Bay St, Toronto', 'Réceptionniste', 45000, 10),
('333-444-011', 'Sophie Chen', '400 Davie St, Vancouver', 'Réceptionniste', 45000, 11),
('333-444-012', 'Antoine Mercier', '1200 Rue Peel, Montreal', 'Réceptionniste', 45000, 12),
('333-444-013', 'Emily Davis', '1500 Woodward Ave, Detroit', 'Réceptionniste', 45000, 13),
('333-444-014', 'Robert Smith', '10 State St, Boston', 'Réceptionniste', 45000, 14),
('333-444-015', 'Maria Garcia', '450 7th Ave, New York', 'Réceptionniste', 45000, 15),
('333-444-016', 'Paul Anderson', '111 Nicollet Mall, Minneapolis', 'Réceptionniste', 45000, 16),
('333-444-017', 'Oliver Brown', '250 Front St W, Toronto', 'Réceptionniste', 45000, 17),
('333-444-018', 'Isabella Taylor', '999 Canada Place, Vancouver', 'Réceptionniste', 45000, 18),
('333-444-019', 'Lucas Martin', '600 4th St SW, Calgary', 'Réceptionniste', 45000, 19),
('333-444-020', 'Emma Petit', '150 Rue Sainte-Catherine, Montreal', 'Réceptionniste', 45000, 20),
('333-444-021', 'William Clark', '233 S Wacker Dr, Chicago', 'Réceptionniste', 45000, 21),
('333-444-022', 'Zoe Walker', '1301 2nd Ave, Seattle', 'Réceptionniste', 45000, 22),
('333-444-023', 'Noah Scott', '111 Congress Ave, Austin', 'Réceptionniste', 45000, 23),
('333-444-024', 'Mia Adams', '200 Main St, Los Angeles', 'Réceptionniste', 45000, 24),
('333-444-025', 'Gabriel Roy', '300 Laurier Ave, Ottawa', 'Réceptionniste', 45000, 25),
('333-444-026', 'Sandrine Tremblay', '2050 Rue Mansfield, Montreal', 'Réceptionniste', 45000, 26),
('333-444-027', 'Benjamin Lee', '55 York St, Toronto', 'Réceptionniste', 45000, 27),
('333-444-028', 'Alyssa Wong', '1011 W Cordova St, Vancouver', 'Réceptionniste', 45000, 28),
('333-444-029', 'Hugo Bouchard', '700 Centre St S, Calgary', 'Réceptionniste', 45000, 29),
('333-444-030', 'Ava Wright', '411 E Wisconsin Ave, Milwaukee', 'Réceptionniste', 45000, 30),
('333-444-031', 'Samuel Green', '2 N Central Ave, Phoenix', 'Réceptionniste', 45000, 31),
('333-444-032', 'Charlotte King', '1535 Broadway, New York', 'Réceptionniste', 45000, 32),
('333-444-033', 'Justin Fortin', '2 Elgin St, Ottawa', 'Réceptionniste', 45000, 33),
('333-444-034', 'Maya Dubois', '1100 Melville St, Vancouver', 'Réceptionniste', 45000, 34),
('333-444-035', 'Liam Gauthier', '65 Front St W, Toronto', 'Réceptionniste', 45000, 35),
('333-444-036', 'Alice Morin', '1000 Rue de la Gauchetière, Montreal', 'Réceptionniste', 45000, 36),
('333-444-037', 'Nathan Lavoie', '200 Barclay Parade SW, Calgary', 'Réceptionniste', 45000, 37),
('333-444-038', 'Sofia Martinez', '1200 Ross Ave, Dallas', 'Réceptionniste', 45000, 38),
('333-444-039', 'Arthur Jenkins', '5th Ave & 59th St, New York', 'Réceptionniste', 45000, 39),
('333-444-040', 'Victoria Fisher', '1400 6th Ave, Seattle', 'Réceptionniste', 45000, 40);