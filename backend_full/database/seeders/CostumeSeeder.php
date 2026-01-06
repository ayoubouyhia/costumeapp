<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class CostumeSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        DB::table('categories')->insertOrIgnore([
            'id' => 1,
            'name' => 'Costumes',
        ]);

        DB::table('costumes')->insert([
            [
                'id' => 1,
                'name' => 'Notte (Bleu Roi)',
                'description' => 'Une élégance royale pour vos soirées les plus prestigieuses.',
                'size' => 'M',
                'price' => 450.00,
                'category_id' => 1,
                'quantity' => 10,
                'is_available' => true,
                'image_path' => 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_0009_Homme-en-Costume-Elegant_remix_01jz43xe9te1zsvggxvd49ce3e.png',
            ],
            [
                'id' => 2,
                'name' => 'Noir Éternel',
                'description' => 'Le classique intemporel. Une coupe parfaite.',
                'size' => 'L',
                'price' => 500.00,
                'category_id' => 1,
                'quantity' => 10,
                'is_available' => true,
                'image_path' => 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_0101_Costume-Elegant-et-Moderne_remix_01jz46x95fef5vhd34cgb7vn1s.png',
            ],
            [
                'id' => 3,
                'name' => 'Midnight Pinstripes',
                'description' => 'L\'audace des rayures fines sur un fond sombre.',
                'size' => 'L',
                'price' => 550.00,
                'category_id' => 1,
                'quantity' => 10,
                'is_available' => true,
                'image_path' => 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_0117_Homme-en-Costume-Elegant_remix_01jz47tp3rfpd9ea1rj7s47zna.png',
            ],
            [
                'id' => 4,
                'name' => 'Bordeaux Majestic',
                'description' => 'Osez la couleur avec ce bordeaux profond.',
                'size' => 'M',
                'price' => 600.00,
                'category_id' => 1,
                'quantity' => 10,
                'is_available' => true,
                'image_path' => 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_2144_Modele-en-Costume-Classique_remix_01jz6e04x2fz1tcw017rmec251.png',
            ],
            [
                'id' => 5,
                'name' => 'Gris Manhattan',
                'description' => 'Le chic urbain par excellence.',
                'size' => 'XL',
                'price' => 650.00,
                'category_id' => 1,
                'quantity' => 10,
                'is_available' => true,
                'image_path' => 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_0241_Homme-en-Costume-Bleu_remix_01jz4ckh07e7mt37s684jvw0zt.png',
            ],
            [
                'id' => 6,
                'name' => 'Brun Toscane',
                'description' => 'Chaleur et distinction.',
                'size' => 'L',
                'price' => 550.00,
                'category_id' => 1,
                'quantity' => 10,
                'is_available' => true,
                'image_path' => 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_1539_Homme-en-costume-elegant_remix_01jz5s3v42ez3vtgbjpdagv744.png',
            ],
            [
                'id' => 7,
                'name' => 'Prince de Galles',
                'description' => 'Le motif iconique pour une allure british.',
                'size' => 'M',
                'price' => 700.00,
                'category_id' => 1,
                'quantity' => 10,
                'is_available' => true,
                'image_path' => 'https://amen-bespoke.com/wp-content/uploads/2025/07/20250702_2358_Modele-en-Costume-Elegant_remix_01jz6npvjyecxtwztb18fwgg8p.png',
            ],
            [
                'id' => 8,
                'name' => 'Smoking Blanc',
                'description' => 'L\'apogée du luxe pour vos mariages.',
                'size' => 'M',
                'price' => 800.00,
                'category_id' => 1,
                'quantity' => 10,
                'is_available' => true,
                'image_path' => 'https://wp-media-dejiandkola.s3.eu-west-2.amazonaws.com/2020/09/120089573_3780074748688104_995916302928762415_n.jpg',
            ],
        ]);
    }
}
