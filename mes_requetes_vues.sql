CREATE OR REPLACE VIEW vue_chambres_dispo_par_zone AS
SELECT 
    h.address AS zone,
    COUNT(hc.room_number) AS total_chambres_disponibles
FROM public.hotel h
JOIN public.hotelcontains hc ON h.hotel_id = hc.hotel_id
WHERE hc.room_number NOT IN (
    SELECT room_number FROM public.booking WHERE CURRENT_DATE >= start_date AND CURRENT_DATE < end_date
)
AND hc.room_number NOT IN (
    SELECT room_number FROM public.renting WHERE CURRENT_DATE >= start_date AND CURRENT_DATE < end_date
)
GROUP BY h.address;


CREATE OR REPLACE VIEW vue_capacite_totale_hotel AS
SELECT 
    h.hotel_id,
    h.address AS hotel_zone,
    COUNT(hc.room_number) AS nombre_total_chambres,
    SUM(
        CASE r.capacity 
            WHEN 'Simple' THEN 1 
            WHEN 'Double' THEN 2 
            WHEN 'Triple' THEN 3 
            WHEN 'Queen' THEN 4 -- Ajuste ici selon tes préférences
            WHEN 'King' THEN 4  -- Ajuste ici selon tes préférences
            ELSE 2 
        END
    ) AS capacite_totale_personnes
FROM public.hotel h
JOIN public.hotelcontains hc ON h.hotel_id = hc.hotel_id
JOIN public.room r ON hc.room_number = r.room_number
GROUP BY h.hotel_id, h.address;


