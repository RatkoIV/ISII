% ISII: Integralni C-T-S indeks sličnosti slike

% Postavljanje preciznosti prikaza rezultata
format long;

% Pokušaj učitavanja ulaznih slika uz hvatanje grešaka
try
    img1 = imread('F:\Education\RADOVI\Slike za analizu\Skywallker.tif');
    img2 = imread('C:\Users\Bato\Desktop\RADOVI 2024\ISII\Slike\Skywallker\7mipikselGkanalza1.tif');
catch ME
    error('Greška pri učitavanju slika: %s', ME.message);
end

% Konstante koje sprečavaju deljenje nulom
C1 = 1e-4;
C2 = 1e-4;

% Faktori skaliranja
structural_scale_factor = 0.25;
color_scale_factor = 4;

% Provera da li slike imaju iste dimenzije
[m1, n1, c1] = size(img1);
[m2, n2, c2] = size(img2);

if c1 ~= c2 || m1 ~= m2 || n1 ~= n2
    error('Ulazne slike moraju imati iste dimenzije');
end

% Konvertovanje slika u double preciznost
img1 = double(img1);
img2 = double(img2);

%% Izračunavanje strukturne sličnosti
structural_similarity = 0;

for x = 1:m1
    for y = 1:n1
        dx_img1 = img1(max(x-1, 1), y, :) - img1(x, y, :);
        dy_img1 = img1(x, max(y-1, 1), :) - img1(x, y, :);
        
        dx_img2 = img2(max(x-1, 1), y, :) - img2(x, y, :);
        dy_img2 = img2(x, max(y-1, 1), :) - img2(x, y, :);
        
        structural_similarity = structural_similarity + (sum((dx_img1 - dx_img2).^2) + sum((dy_img1 - dy_img2).^2)) / ...
                               (sum(dx_img1.^2) + sum(dy_img1.^2) + sum(dx_img2.^2) + sum(dy_img2.^2) + C1);
    end
end

structural_similarity = 1 - structural_similarity / (m1 * n1);
structural_similarity = real(structural_similarity ^ structural_scale_factor);

%% Izračunavanje sličnosti boja
% Konvertovanje slika u grayscale ako već nisu
if size(img1, 3) > 1
    gray_img1 = rgb2gray(img1);
else
    gray_img1 = img1;
end

if size(img2, 3) > 1
    gray_img2 = rgb2gray(img2);
else
    gray_img2 = img2;
end

% Računanje histograma
hist1 = imhist(gray_img1);
hist2 = imhist(gray_img2);

% Računanje kumulativnih histograma
int_hist1 = cumsum(hist1);
int_hist2 = cumsum(hist2);

% Računanje sličnosti boja
numerator = min(int_hist1, int_hist2);
denominator = max(int_hist1, int_hist2);

color_similarity = sum(numerator) / sum(denominator);
color_similarity = color_similarity ^ color_scale_factor;

%% Izračunavanje sličnosti teksture
% Detekcija ivica
edge_img1 = edge(gray_img1, 'Canny');
edge_img2 = edge(gray_img2, 'Canny');

% Pronalaženje pozicija ivica
[edge1_rows, edge1_cols] = find(edge_img1);
[edge2_rows, edge2_cols] = find(edge_img2);

% Izračunavanje poklapanja
common_pixels = numel(intersect([edge1_rows, edge1_cols], [edge2_rows, edge2_cols], 'rows'));
total_pixels = min(numel(edge1_rows), numel(edge2_rows));
texture_similarity = (common_pixels / total_pixels) * 100;
texture_similarity = (texture_similarity / 100) / 2;

%% Integralni C-T-S indeks sličnosti slike
ISII = (structural_similarity + color_similarity + texture_similarity) / 3