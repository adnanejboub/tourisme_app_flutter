-- Script SQL pour insérer les activités et monuments de Casablanca
-- À exécuter sur la base de données du backend
-- Note: id_ville = 2 correspond à Casablanca (d'après la table existante)

-- Supprimer les anciennes entrées de Casablanca pour éviter les doublons
DELETE FROM activite WHERE id_ville = 2 AND id_activite IN (1001, 1002, 1003, 1004, 1005, 2001, 2002);

-- Insérer les activités de Casablanca
INSERT INTO activite (id_activite, nom, categorie, conditions_speciales, duree_minimun, duree_maximun, niveau_dificulta, saison, id_ville) VALUES
-- Activités de Casablanca
(1001, 'Shopping à Casablanca', 'TOURS', 'Centres commerciaux et souks traditionnels', 120, 300, 'Facile', 'Toute l''année', 2),

(1002, 'Restaurants de Casablanca', 'EVENEMENTS', 'Gastronomie marocaine authentique', 90, 180, 'Facile', 'Toute l''année', 2),

(1003, 'Vie nocturne à Casablanca', 'EVENEMENTS', 'Bars, clubs et cafés modernes', 180, 360, 'Facile', 'Toute l''année', 2),

(1004, 'Galerie d''art de Casablanca', 'EVENEMENTS', 'Art contemporain marocain et international', 90, 150, 'Facile', 'Toute l''année', 2),

(1005, 'Business à Casablanca', 'TOURS', 'Centre d''affaires et tours modernes', 120, 240, 'Facile', 'Toute l''année', 2);

-- Insérer les monuments de Casablanca dans la table monument
INSERT INTO monument (id_monument, nom_monument, adresse_monument, description, gratuit, has_culturelle, has_historique, image_url) VALUES
-- Monuments de Casablanca
(2001, 'Mosquée Hassan II', 'Boulevard Sidi Mohammed Ben Abdellah, Casablanca', 'L''une des plus grandes mosquées du monde avec un minaret de 200 mètres. Chef-d''œuvre architectural marocain surplombant l''océan Atlantique.', 0, 'Très élevé', 'Très élevé', 'assets/images/monuments/hassan_ii_mosque.jpg'),

(2002, 'Quartier des Habous', 'Quartier des Habous, Casablanca', 'Quartier traditionnel avec architecture marocaine authentique. Découvrez les souks, les mosquées et l''artisanat local dans un cadre historique préservé.', 1, 'Très élevé', 'Élevé', 'assets/images/monuments/habous_quarter.jpg');

-- Vérifier les insertions des activités
SELECT id_activite, nom, categorie, id_ville FROM activite WHERE id_ville = 2 ORDER BY id_activite;

-- Vérifier les insertions des monuments
SELECT id_monument, nom, adresse_monument, gratuit, has_culturelle, has_historique FROM monument WHERE id_monument IN (2001, 2002) ORDER BY id_monument;
