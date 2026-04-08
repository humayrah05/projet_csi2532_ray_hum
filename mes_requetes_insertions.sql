-- =========================================================
-- LE SCRIPT D'INSERTION MASSIF ET ULTIME (AVEC VARIÉTÉ)
-- =========================================================

-- 1. Chaînes d'Hôtels
INSERT INTO hotel_chain (name, address_of_central_office, number_of_hotels) VALUES
('Marriott', '10400 Fernwood Rd, Bethesda, MD', 8),
('Hilton', '7930 Jones Branch Dr, McLean, VA', 8),
('Hyatt', '150 N Riverside Plaza, Chicago, IL', 8),
('Best Western', '6201 N 24th Pkwy, Phoenix, AZ', 8),
('Fairmont', '100 Wellington St W, Toronto, ON', 8);

-- 2. Hôtels (40 hôtels)
INSERT INTO hotel (address, number_of_rooms, rating) VALUES
('100 Kent St, Ottawa, ON', 5, 4), 
('320 Dalhousie St, Ottawa, ON', 5, 3), 
('1050 De la Gauchetiere St W, Montreal, QC', 5, 4),
('1 Blue Jays Way, Toronto, ON', 5, 5),
('1128 W Hastings St, Vancouver, BC', 5, 4),
('110 9th Ave SE, Calgary, AB', 5, 3),
('1919 Upper Water St, Halifax, NS', 5, 4),
('850 Place d''Youville, Quebec City, QC', 5, 5),
('3 Blvd du Casino, Gatineau, QC', 5, 4),
('145 Richmond St W, Toronto, ON', 5, 3),
('1111 W Georgia St, Vancouver, BC', 5, 5),
('900 boul. René-Lévesque E, Montreal, QC', 5, 4),
('40111 Garfield Rd, MI', 5, 3),
('53 Broad St, Boston, MA', 5, 4),
('100 W 26th St, New York, NY', 5, 3),
('250 Marquette Ave, MN', 5, 5),
('370 King St W, Toronto, ON', 5, 4),
('655 Burrard St, Vancouver, BC', 5, 5),
('2815 24th St NE, Calgary, AB', 5, 3),
('1255 Jeanne-Mance St, Montreal, QC', 5, 4),
('151 E Wacker Dr, Chicago, IL', 5, 5),
('1191 1st Ave, Seattle, WA', 5, 4),
('100 E 8th St, Austin, TX', 5, 3),
('3200 E Mariposa Ave, CA', 5, 4),
('377 O''Connor St, Ottawa, ON', 5, 3),
('1240 Peel St, Montreal, QC', 5, 2), 
('111 Carlton St, Toronto, ON', 5, 3),
('718 Drake St, Vancouver, BC', 5, 2),
('1314 8th St SW, Calgary, AB', 5, 3),
('3200 S Howell Ave, WI', 5, 4),
('6201 N 24th Pkwy, AZ', 5, 3),
('150 W 48th St, New York, NY', 5, 3),
('1 Rideau St, Ottawa, ON', 5, 5),
('900 W Georgia St, Vancouver, BC', 5, 5),
('100 Front St W, Toronto, ON', 5, 4),
('900 Rene Levesque Blvd W, Montreal, QC', 5, 5),
('133 9th Ave SW, Calgary, AB', 5, 5),
('400 Dallas St, Dallas, TX', 5, 4),
('2 E 61st St, New York, NY', 5, 5),
('2000 4th Ave, Seattle, WA', 5, 4);

-- 3. Liaison Hôtel -> Chaîne
INSERT INTO hotelchainhas (name, hotel_id)
SELECT 
    CASE 
        WHEN hotel_id <= 8 THEN 'Marriott'
        WHEN hotel_id <= 16 THEN 'Hilton'
        WHEN hotel_id <= 24 THEN 'Hyatt'
        WHEN hotel_id <= 32 THEN 'Best Western'
        ELSE 'Fairmont'
    END, hotel_id
FROM hotel;

-- 4. Chambres (GÉNÉRATION AVANCÉE ET VARIÉE - C'EST ÇA LE RÉALISME)
INSERT INTO room (room_number, price, capacity, amenities, damage, view, extension)
SELECT
    (h.hotel_id * 1000) + r.num, 
    (h.rating * 80.00) + (r.num * 40.00), 
    CASE r.num 
        WHEN 1 THEN 'Simple' 
        WHEN 2 THEN 'Double' 
        WHEN 3 THEN 'Triple' 
        WHEN 4 THEN 'Queen' 
        ELSE 'King' 
    END,
    CASE (h.hotel_id + r.num) % 4 -- Variété d'équipements
        WHEN 0 THEN 'Wifi haut débit, TV 4K, Machine Nespresso, Minibar'
        WHEN 1 THEN 'Wifi, TV Standard, Climatisation'
        WHEN 2 THEN 'Suite Premium, Jacuzzi, Balcon, Service en chambre 24/7'
        ELSE 'Base, Ventilateur, TV, Literie hypoallergénique'
    END,
    CASE (h.hotel_id * r.num) % 12 -- Variété de dommages (majoritairement Aucun)
        WHEN 1 THEN 'Moquette légèrement tachée'
        WHEN 2 THEN 'Petite égratignure sur le bureau'
        WHEN 3 THEN 'Lampe de chevet clignotante'
        WHEN 4 THEN 'Serrure de la salle de bain rigide'
        ELSE 'Aucun'
    END,
    CASE (h.hotel_id + r.num) % 5 -- Variété de vues
        WHEN 0 THEN 'Vue panoramique sur la ville'
        WHEN 1 THEN 'Vue sur la cour intérieure'
        WHEN 2 THEN 'Vue dégagée'
        WHEN 3 THEN 'Vue sur l''océan / rivière'
        ELSE 'Vue standard (stationnement)'
    END,
    CASE WHEN r.num >= 4 THEN 'Oui' ELSE 'Non' END 
FROM hotel h
CROSS JOIN generate_series(1, 5) as r(num);

-- 5. Liaison Hôtel -> Chambres
INSERT INTO hotelcontains (hotel_id, room_number)
SELECT hotel_id, (hotel_id * 1000) + r.num
FROM hotel
CROSS JOIN generate_series(1, 5) as r(num);

-- 6. TOUS LES EMPLOYÉS (Les 80)
INSERT INTO employee (employee_sin, full_name, address, role_title, role_salary, hotel_id) VALUES
('100000001', 'Yassine Berrada', '120 Rue Wellington, Ottawa', 'Gestionnaire', 85500, 1),
('100000002', 'Jean-Philippe Roy', '45 Ave Laurier, Ottawa', 'Gestionnaire', 78200, 2),
('100000003', 'Amine El Fassi', '210 Rue Sherbrooke, Montreal', 'Gestionnaire', 82400, 3),
('100000004', 'Sarah Thompson', '88 King St W, Toronto', 'Gestionnaire', 91000, 4),
('100000005', 'Karim Mansouri', '500 Robson St, Vancouver', 'Gestionnaire', 88500, 5),
('100000006', 'Marie-Claude Dion', '12 Rue Cartier, Quebec', 'Gestionnaire', 75300, 6),
('100000007', 'Robert MacKenzie', '55 Water St, Halifax', 'Gestionnaire', 72000, 7),
('100000008', 'Fatima Zohra', '850 Place d''Youville, QC', 'Gestionnaire', 89000, 8),
('100000009', 'Simon Lefebvre', '3 Blvd du Casino, Gatineau', 'Gestionnaire', 77000, 9),
('100000010', 'Chloe Bennett', '100 Richmond St W, Toronto', 'Gestionnaire', 84000, 10),
('100000011', 'Pierre Bouchard', '1111 W Georgia, Vancouver', 'Gestionnaire', 95000, 11),
('100000012', 'Hassan Idrissi', '900 Rene-Levesque E, Montreal', 'Gestionnaire', 73000, 12),
('100000013', 'David Smith', '4011 Garfield, Detroit', 'Gestionnaire', 68000, 13),
('100000014', 'Emilie Ouellet', '53 Broad St, Boston', 'Gestionnaire', 81000, 14),
('100000015', 'Nicolas Girard', '100 W 26th St, New York', 'Gestionnaire', 92000, 15),
('100000016', 'Zineb Bennani', '250 Marquette, Minneapolis', 'Gestionnaire', 86000, 16),
('100000017', 'Marc-Andre Fortin', '370 King St W, Toronto', 'Gestionnaire', 79000, 17),
('100000018', 'Isabelle Morin', '655 Burrard, Vancouver', 'Gestionnaire', 87000, 18),
('100000019', 'Tariq El Amrani', '2815 24th St NE, Calgary', 'Gestionnaire', 71000, 19),
('100000020', 'Valerie Gauthier', '1255 Jeanne-Mance, Montreal', 'Gestionnaire', 83000, 20),
('100000021', 'James Wilson', '151 E Wacker, Chicago', 'Gestionnaire', 89000, 21),
('100000022', 'Soufiane Alaoui', '1191 1st Ave, Seattle', 'Gestionnaire', 94000, 22),
('100000023', 'Lucie Gagnon', '100 E 8th St, Austin', 'Gestionnaire', 82000, 23),
('100000024', 'Adam Clarke', '3200 Mariposa, Los Angeles', 'Gestionnaire', 74000, 24),
('100000025', 'Nabil Chraibi', '377 O''Connor, Ottawa', 'Gestionnaire', 70000, 25),
('100000026', 'Camille Cote', '1240 Peel St, Montreal', 'Gestionnaire', 69000, 26),
('100000027', 'Patrick Roy', '111 Carlton, Toronto', 'Gestionnaire', 72000, 27),
('100000028', 'Mouna El Haidari', '718 Drake, Vancouver', 'Gestionnaire', 68500, 28),
('100000029', 'Francois Blais', '1314 8th St, Calgary', 'Gestionnaire', 67000, 29),
('100000030', 'Elena Rossi', '3200 Howell, Milwaukee', 'Gestionnaire', 74500, 30),
('100000031', 'Mehdi Benjelloun', '6201 Pkwy, Phoenix', 'Gestionnaire', 71000, 31),
('100000032', 'Sophie Martin', '150 W 48th, New York', 'Gestionnaire', 73000, 32),
('100000033', 'Hamza Lahlou', '1 Rideau St, Ottawa', 'Gestionnaire', 98000, 33),
('100000034', 'Antoine Mercier', '900 W Georgia, Vancouver', 'Gestionnaire', 96000, 34),
('100000035', 'Léa Lefebvre', '100 Front St W, Toronto', 'Gestionnaire', 94000, 35),
('100000036', 'Youssef Filali', '900 Rene Levesque, Montreal', 'Gestionnaire', 97000, 36),
('100000037', 'Jessica Bergeron', '133 9th Ave, Calgary', 'Gestionnaire', 91000, 37),
('100000038', 'Brahim Tazi', '400 Dallas St, Dallas', 'Gestionnaire', 89500, 38),
('100000039', 'Sandrine Tremblay', '2 E 61st St, New York', 'Gestionnaire', 99500, 39),
('100000040', 'William Baker', '2000 4th Ave, Seattle', 'Gestionnaire', 92000, 40),
('200000001', 'Anas Sbihi', '33 Rue Rideau, Ottawa', 'Réceptionniste', 45000, 1),
('200000002', 'Chloé Dubois', '12 Rue Bank, Ottawa', 'Réceptionniste', 42000, 2),
('200000003', 'Driss Alaoui', '90 Rue Sainte-Catherine, Montreal', 'Réceptionniste', 44000, 3),
('200000004', 'Emily White', '200 Bay St, Toronto', 'Réceptionniste', 48500, 4),
('200000005', 'Rachid Mernissi', '400 Davie St, Vancouver', 'Réceptionniste', 47000, 5),
('200000006', 'Alice Morin', '55 St-Jean, Quebec', 'Réceptionniste', 41000, 6),
('200000007', 'Liam O''Neil', '10 Barrington, Halifax', 'Réceptionniste', 40000, 7),
('200000008', 'Meryem Kabbaj', '12 York St, Quebec', 'Réceptionniste', 46000, 8),
('200000009', 'Sami Touzani', '100 Blvd Greber, Gatineau', 'Réceptionniste', 42500, 9),
('200000010', 'Olivia Taylor', '50 Spadina, Toronto', 'Réceptionniste', 45000, 10),
('200000011', 'Noah Clark', '800 W Pender, Vancouver', 'Réceptionniste', 49000, 11),
('200000012', 'Ines Belkhayat', '450 Rue Peel, Montreal', 'Réceptionniste', 43000, 12),
('200000013', 'Jacob Evans', '1500 Woodward, Detroit', 'Réceptionniste', 39000, 13),
('200000014', 'Ava Martinez', '22 School St, Boston', 'Réceptionniste', 44500, 14),
('200000015', 'Othmane Sijilmassi', '300 5th Ave, New York', 'Réceptionniste', 50000, 15),
('200000016', 'Mia Walker', '11 Nicollet, Minneapolis', 'Réceptionniste', 46000, 16),
('200000017', 'Thomas Girard', '250 Front St, Toronto', 'Réceptionniste', 44000, 17),
('200000018', 'Kenza Guessous', '1011 W Cordova, Vancouver', 'Réceptionniste', 48000, 18),
('200000019', 'Lucas Petit', '600 4th St, Calgary', 'Réceptionniste', 41500, 19),
('200000020', 'Sara Mansouri', '150 Ste-Catherine, Montreal', 'Réceptionniste', 44500, 20),
('200000021', 'William Davis', '233 S Wacker, Chicago', 'Réceptionniste', 47500, 21),
('200000022', 'Jalil Berrada', '1301 2nd Ave, Seattle', 'Réceptionniste', 49000, 22),
('200000023', 'Emma Leduc', '111 Congress, Austin', 'Réceptionniste', 43500, 23),
('200000024', 'Walid Sebti', '200 Main St, Los Angeles', 'Réceptionniste', 42000, 24),
('200000025', 'Gabriel Roy', '300 Laurier, Ottawa', 'Réceptionniste', 41000, 25),
('200000026', 'Lina El Yazidi', '2050 Rue Mansfield, Montreal', 'Réceptionniste', 40500, 26),
('200000027', 'Benjamin Lee', '55 York St, Toronto', 'Réceptionniste', 42500, 27),
('200000028', 'Randa Tazi', '1055 Canada Place, Vancouver', 'Réceptionniste', 41000, 28),
('200000029', 'Hugo Bouchard', '700 Centre St, Calgary', 'Réceptionniste', 40000, 29),
('200000030', 'Ava Wright', '411 Wisconsin, Milwaukee', 'Réceptionniste', 41500, 30),
('200000031', 'Kamal Oudghiri', '2 Central Ave, Phoenix', 'Réceptionniste', 43000, 31),
('200000032', 'Charlotte King', '1535 Broadway, NY', 'Réceptionniste', 44000, 32),
('200000033', 'Reda El Alami', '2 Elgin St, Ottawa', 'Réceptionniste', 52000, 33),
('200000034', 'Maya Dubois', '1100 Melville, Vancouver', 'Réceptionniste', 51000, 34),
('200000035', 'Liam Gauthier', '65 Front St, Toronto', 'Réceptionniste', 50000, 35),
('200000036', 'Houda Benani', '1000 De la Gauchetiere, Montreal', 'Réceptionniste', 52500, 36),
('200000037', 'Nathan Lavoie', '200 Barclay SW, Calgary', 'Réceptionniste', 49500, 37),
('200000038', 'Sofia Martinez', '1200 Ross Ave, Dallas', 'Réceptionniste', 48000, 38),
('200000039', 'Mehdi El Glaoui', '59th St & 5th Ave, NY', 'Réceptionniste', 54000, 39),
('200000040', 'Victoria Fisher', '1400 6th Ave, Seattle', 'Réceptionniste', 50500, 40);

-- Liaisons Employés -> Hôtels
INSERT INTO worksfor (employee_sin, hotel_id) 
SELECT employee_sin, hotel_id FROM employee;

INSERT INTO manages (hotel_id, employee_sin) 
SELECT hotel_id, employee_sin FROM employee WHERE role_title = 'Gestionnaire';

-- 7. TOUS LES CLIENTS (Les 150 - AUCUNE COLOCATION FORCÉE)
INSERT INTO customer (customer_sin, full_name, address, type_of_id, registration_date, room_number) VALUES
('900000001', 'Omar Berrada', 'Casablanca', 'Passeport', '2025-01-10', 1001),
('900000002', 'Jean-Luc Moreau', 'Paris', 'Passeport', '2025-02-15', 1002),
('900000003', 'Hiba El Mansouri', 'Rabat', 'Passeport', '2025-03-20', 1003),
('900000004', 'Mark Zuckerberg', 'California', 'Driving License', '2025-04-05', 1004),
('900000005', 'Isabelle Huppert', 'Cannes', 'Passeport', '2025-05-12', 1005),
('900000006', 'Khalid Tazi', 'Tanger', 'Passeport', '2025-06-18', 2001),
('900000007', 'Pierre-Yves Lefebvre', 'Lyon', 'Permis', '2025-07-22', 2002),
('900000008', 'Salma El Haidari', 'Rabat', 'Passeport', '2025-08-30', 2003),
('900000009', 'Brian Gelroui', 'Ottawa', 'SIN', '2026-03-01', 2004),
('900000010', 'Humya Binuisi', 'Ottawa', 'SIN', '2026-03-05', 2005),
('900000011', 'Mehdi Ben Barka', 'Montreal', 'Passeport', '2026-03-10', 3001),
('900000012', 'Lucie St-Pierre', 'Gatineau', 'Driving License', '2026-03-12', 3002),
('900000013', 'Tarik Jandal', 'Casablanca', 'Passeport', '2026-03-15', 3003),
('900000014', 'Famille Dupont', 'Lille', 'Permis', '2025-09-01', 3004),
('900000015', 'Ahmed El Guerrouj', 'Ifrane', 'Passeport', '2025-09-10', 3005),
('900000016', 'Marie-Claire Petit', 'Marseille', 'Permis', '2025-09-15', 4001),
('900000017', 'Kevin Tremblay', 'Saguenay', 'SIN', '2025-09-20', 4002),
('900000018', 'Sami Zayn', 'Montreal', 'Passport', '2026-01-01', 4003),
('900000019', 'Zinédine Zidane', 'Madrid', 'Passport', '2026-01-05', 4004),
('900000020', 'Gad Elmaleh', 'Casablanca', 'Passport', '2026-01-10', 4005),
('900000021', 'Stromae Van Haver', 'Bruxelles', 'Passport', '2026-01-15', 5001),
('900000022', 'Celine Dion', 'Las Vegas', 'Passport', '2026-01-20', 5002),
('900000023', 'Jamal Debbouze', 'Paris', 'Passport', '2026-01-25', 5003),
('900000024', 'Noura El Kaoutari', 'Fes', 'Passport', '2026-02-01', 5004),
('900000025', 'Julien Doré', 'Nimes', 'Permis', '2026-02-05', 5005),
('900000026', 'Leila Bekhti', 'Paris', 'Passport', '2026-02-10', 6001),
('900000027', 'Badr Hari', 'Kenitra', 'Passport', '2026-02-15', 6002),
('900000028', 'Angelina Jolie', 'Los Angeles', 'Passport', '2026-02-20', 6003),
('900000029', 'Abdellah Taïa', 'Sale', 'Passport', '2026-02-25', 6004),
('900000030', 'Virginie Efira', 'Bruxelles', 'Permis', '2026-03-01', 6005),
('900000031', 'Sofiane Boufal', 'Angers', 'Passport', '2025-12-01', 7001),
('900000032', 'Achraf Hakimi', 'Madrid', 'Passeport', '2025-12-05', 7002),
('900000033', 'Kylian Mbappé', 'Bondy', 'Passeport', '2025-12-10', 7003),
('900000034', 'Faouzi Lekjaa', 'Oujda', 'Passeport', '2025-12-15', 7004),
('900000035', 'Nawal El Moutawakel', 'Casablanca', 'Passeport', '2025-12-20', 7005),
('900000036', 'Saïd Taghmaoui', 'Villepinte', 'Passeport', '2025-12-25', 8001),
('900000037', 'RedOne Khayat', 'Tetouan', 'Passport', '2025-12-30', 8002),
('900000038', 'Karim Benzema', 'Lyon', 'Passeport', '2026-01-02', 8003),
('900000039', 'Mustapha Hadji', 'Ifrane', 'Passeport', '2026-01-08', 8004),
('900000040', 'Zouhair Bahaoui', 'Tetouan', 'Passeport', '2026-01-12', 8005),
('900000041', 'Saad Lamjarred', 'Rabat', 'Passeport', '2026-01-18', 33001),
('900000042', 'Asmae Lmnawar', 'Casablanca', 'Passeport', '2026-01-22', 33002),
('900000043', 'Manal Benchakha', 'Marrakech', 'Passeport', '2026-01-28', 33003),
('900000044', 'Dizzy DROS', 'Casablanca', 'Passeport', '2026-02-05', 33004),
('900000045', 'Lartiste Onfroy', 'Imintanoute', 'Passeport', '2026-02-12', 33005),
('900000046', 'ElGrandeToto', 'Casablanca', 'Passeport', '2026-02-18', 34001),
('900000047', 'Justin Bieber', 'Stratford', 'Passport', '2026-03-01', 34002),
('900000048', 'The Weeknd', 'Scarborough', 'Passport', '2026-03-05', 34003),
('900000049', 'Drake Graham', 'Forest Hill', 'Passport', '2026-03-10', 34004),
('900000050', 'Ryan Gosling', 'London', 'Passport', '2026-03-15', 34005),
('900000051', 'Rachel McAdams', 'London', 'Passport', '2026-03-20', 35001),
('900000052', 'Jim Carrey', 'Newmarket', 'Passport', '2026-03-22', 35002),
('900000053', 'Michael Cera', 'Brampton', 'Passport', '2026-03-25', 35003),
('900000054', 'Seth Rogen', 'Vancouver', 'Passport', '2026-03-28', 35004),
('900000055', 'Elliot Page', 'Halifax', 'Passport', '2026-03-30', 35005),
('900000056', 'Shania Twain', 'Windsor', 'Passport', '2026-04-01', 36001),
('900000057', 'Avril Lavigne', 'Belleville', 'Passport', '2026-04-02', 36002),
('900000058', 'Shawn Mendes', 'Pickering', 'Passport', '2026-04-03', 36003),
('900000059', 'Carly Rae Jepsen', 'Mission', 'Passport', '2026-04-04', 36004),
('900000060', 'deadmau5 Joel', 'Niagara Falls', 'Passport', '2026-04-05', 36005),
('900000061', 'Youssef En-Nesyri', 'Fes', 'Passeport', '2026-02-10', 37001),
('900000062', 'Nayef Aguerd', 'Kenitra', 'Passeport', '2026-02-12', 37002),
('900000063', 'Bono Yassine', 'Montreal', 'Passport', '2026-02-15', 37003),
('900000064', 'Walid Regragui', 'Corbeil-Essonnes', 'Passeport', '2026-02-20', 37004),
('900000065', 'Azzedine Ounahi', 'Casablanca', 'Passeport', '2026-02-22', 37005),
('900000066', 'Sofyan Amrabat', 'Huizen', 'Passeport', '2026-02-25', 38001),
('900000067', 'Noussair Mazraoui', 'Leiderdorp', 'Passeport', '2026-02-28', 38002),
('900000068', 'Yahya Attiat-Allah', 'Safi', 'Passeport', '2026-03-02', 38003),
('900000069', 'Jawad El Yamiq', 'Khouribga', 'Passeport', '2026-03-05', 38004),
('900000070', 'Selim Amallah', 'Hautrage', 'Passeport', '2026-03-08', 38005),
('900000071', 'Anass Zaroury', 'Malines', 'Passeport', '2026-03-10', 39001),
('900000072', 'Bilal El Khannouss', 'Strombeek-Bever', 'Passeport', '2026-03-12', 39002),
('900000073', 'Abdessamad Ezzalzouli', 'Beni Mellal', 'Passeport', '2026-03-15', 39003),
('900000074', 'Zakaria Aboukhlal', 'Rotterdam', 'Passeport', '2026-03-18', 39004),
('900000075', 'Abdelhamid Sabiri', 'Goulmima', 'Passeport', '2026-03-20', 39005),
('900000076', 'Ilias Chair', 'Anvers', 'Passeport', '2026-03-22', 40001),
('900000077', 'Walid Cheddira', 'Lorette', 'Passeport', '2026-03-25', 40002),
('900000078', 'Hamdallah Abderrazak', 'Safi', 'Passeport', '2026-03-28', 40003),
('900000079', 'Munir Mohamedi', 'Melilla', 'Passeport', '2026-03-30', 40004),
('900000080', 'Ahmed Reda Tagnaouti', 'Fes', 'Passeport', '2026-04-01', 40005),
('900000081', 'Mick Jagger', 'UK', 'Passport', '2026-01-10', 9001),
('900000082', 'Keith Richards', 'UK', 'Passport', '2026-01-12', 9002),
('900000083', 'Paul McCartney', 'UK', 'Passport', '2026-01-15', 9003),
('900000084', 'Ringo Starr', 'UK', 'Passport', '2026-01-18', 9004),
('900000085', 'Elton John', 'UK', 'Passport', '2026-01-20', 9005),
('900000086', 'Freddie Mercury', 'TAN', 'Passport', '2026-01-22', 10001),
('900000087', 'David Bowie', 'UK', 'Passport', '2026-01-25', 10002),
('900000088', 'Amy Winehouse', 'UK', 'Passport', '2026-01-28', 10003),
('900000089', 'Adele Adkins', 'UK', 'Passport', '2026-01-30', 10004),
('900000090', 'Ed Sheeran', 'UK', 'Passport', '2026-02-01', 10005),
('900000091', 'Dany Boon', 'FRA', 'Passeport', '2026-02-05', 11001),
('900000092', 'Marion Cotillard', 'FRA', 'Passeport', '2026-02-08', 11002),
('900000093', 'Jean Dujardin', 'FRA', 'Passeport', '2026-02-12', 11003),
('900000094', 'Omar Sy', 'FRA', 'Passeport', '2026-02-15', 11004),
('900000095', 'Vincent Cassel', 'FRA', 'Passeport', '2026-02-18', 11005),
('900000096', 'Eva Green', 'FRA', 'Passeport', '2026-02-22', 12001),
('900000097', 'Guillaume Canet', 'FRA', 'Passeport', '2026-02-25', 12002),
('900000098', 'Audrey Tautou', 'FRA', 'Passeport', '2026-02-28', 12003),
('900000099', 'Lea Seydoux', 'FRA', 'Passeport', '2026-03-02', 12004),
('900000100', 'Gaspard Ulliel', 'FRA', 'Passeport', '2026-03-05', 12005),
('900000101', 'Tahiti Bob', 'USA', 'SIN', '2026-03-08', 13001),
('900000102', 'Bartholomew Simpson', 'USA', 'SIN', '2026-03-10', 13002),
('900000103', 'Lisa Simpson', 'USA', 'SIN', '2026-03-12', 13003),
('900000104', 'Homer Simpson', 'USA', 'SIN', '2026-03-15', 13004),
('900000105', 'Marge Simpson', 'USA', 'SIN', '2026-03-18', 13005),
('900000106', 'Ned Flanders', 'USA', 'SIN', '2026-03-20', 14001),
('900000107', 'Charles Montgomery Burns', 'USA', 'SIN', '2026-03-22', 14002),
('900000108', 'Waylon Smithers', 'USA', 'SIN', '2026-03-25', 14003),
('900000109', 'Apu Nahasapeemapetilon', 'USA', 'SIN', '2026-03-28', 14004),
('900000110', 'Moe Szyslak', 'USA', 'SIN', '2026-03-30', 14005),
('900000111', 'Barney Gumble', 'USA', 'SIN', '2026-04-01', 15001),
('900000112', 'Seymour Skinner', 'USA', 'SIN', '2026-04-02', 15002),
('900000113', 'Edna Krabappel', 'USA', 'SIN', '2026-04-03', 15003),
('900000114', 'Milhouse Van Houten', 'USA', 'SIN', '2026-04-04', 15004),
('900000115', 'Nelson Muntz', 'USA', 'SIN', '2026-04-05', 15005),
('900000116', 'Ralph Wiggum', 'USA', 'SIN', '2026-04-06', 16001),
('900000117', 'Clancy Wiggum', 'USA', 'SIN', '2026-04-07', 16002),
('900000118', 'Fat Tony', 'USA', 'SIN', '2026-04-08', 16003),
('900000119', 'Krusty The Clown', 'USA', 'SIN', '2026-04-09', 16004),
('900000120', 'Sideshow Mel', 'USA', 'SIN', '2026-04-10', 16005),
('900000121', 'Ziad Rahbani', 'LIB', 'Passport', '2026-01-05', 17001),
('900000122', 'Fairuz Haddad', 'LIB', 'Passport', '2026-01-10', 17002),
('900000123', 'Marcel Khalife', 'LIB', 'Passport', '2026-01-15', 17003),
('900000124', 'Julia Boutros', 'LIB', 'Passport', '2026-01-20', 17004),
('900000125', 'Nancy Ajram', 'LIB', 'Passport', '2026-01-25', 17005),
('900000126', 'Haifa Wehbe', 'LIB', 'Passport', '2026-02-01', 18001),
('900000127', 'Elissa Khoury', 'LIB', 'Passport', '2026-02-05', 18002),
('900000128', 'Najwa Karam', 'LIB', 'Passport', '2026-02-10', 18003),
('900000129', 'Ragheb Alama', 'LIB', 'Passport', '2026-02-15', 18004),
('900000130', 'Assi El Helani', 'LIB', 'Passport', '2026-02-20', 18005),
('900000131', 'Amr Diab', 'EGY', 'Passport', '2026-02-25', 19001),
('900000132', 'Tamer Hosny', 'EGY', 'Passport', '2026-03-01', 19002),
('900000133', 'Sherine Abdel-Wahab', 'EGY', 'Passport', '2026-03-05', 19003),
('900000134', 'Mohamed Ramadan', 'EGY', 'Passport', '2026-03-10', 19004),
('900000135', 'Angham Mohamed', 'EGY', 'Passport', '2026-03-15', 19005),
('900000136', 'Kadim Al Sahir', 'IRQ', 'Passport', '2026-03-20', 20001),
('900000137', 'Majid Al Mohandis', 'IRQ', 'Passport', '2026-03-25', 20002),
('900000138', 'Ahlam Al Shamsi', 'UAE', 'Passport', '2026-03-30', 20003),
('900000139', 'Hussain Al Jassmi', 'UAE', 'Passport', '2026-04-01', 20004),
('900000140', 'Balqees Ahmed', 'UAE', 'Passport', '2026-04-02', 20005),
('900000141', 'Dalia Mubarak', 'KSA', 'Passport', '2026-04-03', 21001),
('900000142', 'Rashed Al-Majed', 'BHR', 'Passport', '2026-04-04', 21002),
('900000143', 'Abdul Majeed Abdullah', 'KSA', 'Passport', '2026-04-05', 21003),
('900000144', 'Asala Nasri', 'SYR', 'Passport', '2026-04-06', 21004),
('900000145', 'Nassif Zeytoun', 'SYR', 'Passport', '2026-04-07', 21005),
('900000146', 'George Wassouf', 'SYR', 'Passport', '2026-04-08', 22001),
('900000147', 'Saber Rebaï', 'TUN', 'Passport', '2026-04-09', 22002),
('900000148', 'Latifa Arfaoui', 'TUN', 'Passport', '2026-04-10', 22003),
('900000149', 'Dhafer L''Abidine', 'TUN', 'Passport', '2026-04-11', 22004),
('900000150', 'Hend Sabri', 'TUN', 'Passport', '2026-04-12', 22005);


-- =========================================================
-- LA LOGIQUE DE OUF: BOOKING ET RENTING AVEC DATES ET SANS COLOCATION
-- =========================================================

-- 1. TOUS les 150 clients obtiennent une RÉSERVATION (Booking)
INSERT INTO booking (room_number, start_date, end_date)
SELECT 
    room_number, 
    registration_date, 
    registration_date + INTERVAL '7 days'
FROM customer
WHERE room_number IS NOT NULL;

-- 2. On attache le client à sa réservation
INSERT INTO customerreserves (customer_sin, room_number, booking_number)
SELECT 
    c.customer_sin, 
    c.room_number, 
    b.booking_number
FROM customer c
JOIN booking b ON c.room_number = b.room_number;

-- 3. La moitié des gens (75 clients) SONT DÉJÀ LÀ (Renting)
INSERT INTO renting (room_number, start_date, end_date)
SELECT 
    room_number, 
    start_date, 
    end_date
FROM booking
WHERE booking_number % 2 = 0;

-- 4. On relie la location (Renting) à la réservation originale
INSERT INTO roomhas (booking_number, renting_number)
SELECT 
    b.booking_number, 
    r.renting_number
FROM booking b
JOIN renting r ON b.room_number = r.room_number
WHERE b.booking_number % 2 = 0;
