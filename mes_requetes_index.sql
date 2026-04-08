CREATE INDEX idx_booking_dates ON public.booking(start_date, end_date);

CREATE INDEX idx_hotelcontains_hotel ON public.hotelcontains(hotel_id);

CREATE INDEX idx_hotel_address ON public.hotel(address);