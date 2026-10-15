-- 1. Crear la tabla de imágenes vinculada a los usuarios de Supabase Auth
create table if not exists public.galeria_imagenes (
    id uuid default gen_random_uuid() primary key,
    user_id uuid references auth.users(id) on delete cascade not null,
    imagen_url text not null,
    nombre_archivo text,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. Habilitar la seguridad a nivel de filas (RLS) para proteger los datos
alter table public.galeria_imagenes enable row level security;

-- 3. Eliminar políticas previas si ya existen para evitar conflictos
drop policy if exists "Usuarios pueden ver sus propias imágenes" on public.galeria_imagenes;
drop policy if exists "Usuarios pueden subir sus propias imágenes" on public.galeria_imagenes;
drop policy if exists "Usuarios pueden eliminar sus propias imágenes" on public.galeria_imagenes;

-- 4. Volver a crear las políticas de seguridad
create policy "Usuarios pueden ver sus propias imágenes"
    on public.galeria_imagenes
    for select
    using (auth.uid() = user_id);

create policy "Usuarios pueden subir sus propias imágenes"
    on public.galeria_imagenes
    for insert
    with check (auth.uid() = user_id);

create policy "Usuarios pueden eliminar sus propias imágenes"
    on public.galeria_imagenes
    for delete
    using (auth.uid() = user_id);