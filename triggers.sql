-- Triggers
-- Trigger 1 : Mise à jour automatique du nombre d'hôtels dans une chaîne.
CREATE OR REPLACE FUNCTION update_hotel_count() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        UPDATE Hotel_Chain SET number_of_hotels = number_of_hotels + 1 WHERE name = NEW.chain_name;
    ELSIF (TG_OP = 'DELETE') THEN
        UPDATE Hotel_Chain SET number_of_hotels = number_of_hotels - 1 WHERE name = OLD.chain_name;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_hotel_count
AFTER INSERT OR DELETE ON Hotel FOR EACH ROW EXECUTE FUNCTION update_hotel_count();

-- Trigger 2 : Archivage automatique lors de la suppression d'une réservation.
CREATE OR REPLACE FUNCTION archive_booking() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO Archive (number_of_bookings) VALUES (1);
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_archive_on_delete
BEFORE DELETE ON Booking FOR EACH ROW EXECUTE FUNCTION archive_booking();