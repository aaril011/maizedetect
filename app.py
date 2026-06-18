from flask import Flask, request, jsonify
from tensorflow.keras.models import load_model
from PIL import Image
import numpy as np
import json

app = Flask(__name__)

# ===============================
# PATH MODEL DAN JSON
# ===============================
MODEL_PATH = "E:\\IRMA\\api1\\model\\model_mobilenetv2_jagung_finetuned.keras"
CLASS_NAMES_PATH = "E:\\IRMA\\api1\\model\\class_names(v2).json"
disease_info = {
    "Daun_Karat_(Puccinia_Sorghi)": {
        "penyebab":
        "Karat daun pada tanaman jagung disebabkan oleh jamur Puccinia polysora yang menyerang bagian daun. Penyakit berkembang lebih cepat pada kondisi kelembapan udara dan tanah yang tinggi.",

        "solusi": [
            "Menggunakan bibit jagung yang tahan terhadap penyakit karat daun.",
            "Mengatur jadwal tanam pada periode Maret–April atau awal Oktober–November.",
            "Menjaga kelembapan tanah dan menghindari lahan yang terlalu basah.",
            "Melakukan pengairan ketika tanah mulai kering.",
            "Menggunakan fungisida sesuai rekomendasi apabila serangan sudah berkembang."
        ]
    },

    "Daun_Hawar_(Exserohilum_Turcicum)": {
        "penyebab":
        "Hawar daun disebabkan oleh jamur Exserohilum turcicum yang menyerang jaringan daun. Penyakit berkembang pada lingkungan yang lembap dengan curah hujan tinggi dan sirkulasi udara yang kurang baik.",

        "solusi": [
            "Menggunakan varietas jagung yang tahan terhadap penyakit hawar daun.",
            "Melakukan penanaman pada waktu yang sesuai.",
            "Mengatur jarak tanam agar sirkulasi udara lebih baik.",
            "Mengatur sistem pengairan dan memberikan air saat tanah mulai kering.",
            "Menghilangkan bagian daun yang telah terinfeksi."
        ]
    },

    "Daun_Bulai_(Genus_Peronosclerospora)": {
        "penyebab":
        "Penyakit bulai disebabkan oleh patogen Peronosclerospora maydis yang menyerang tanaman terutama pada fase awal pertumbuhan. Penyakit berkembang cepat pada kondisi kelembapan tinggi dan tanah yang terlalu basah.",

        "solusi": [
            "Menggunakan bibit yang tahan terhadap penyakit bulai.",
            "Melakukan penanaman pada waktu yang tepat.",
            "Melakukan perlakuan benih sebelum penanaman.",
            "Menjaga kelembapan tanah agar tidak berlebihan.",
            "Melakukan pengairan ketika tanah mulai kering."
        ]
    },

    "Daun_Sehat_(Zea_Mays)": {
        "penyebab":
        "Daun sehat menunjukkan tanaman memperoleh nutrisi, air, dan cahaya yang cukup serta tidak mengalami serangan jamur maupun patogen.",

        "solusi": [
            "Menggunakan bibit berkualitas.",
            "Memberikan pupuk sesuai kebutuhan tanaman.",
            "Menjaga kelembapan tanah tetap stabil.",
            "Melakukan pengairan ketika tanah mulai kering.",
            "Memperhatikan jadwal tanam yang sesuai.",
            "Melakukan pemantauan tanaman secara rutin."
        ]
    }
}

# ===============================
# LOAD MODEL DAN CLASS NAMES
# ===============================
model = load_model(MODEL_PATH)

with open(CLASS_NAMES_PATH, "r") as f:
    class_names = json.load(f)

# ===============================
# UKURAN INPUT MODEL
# Sesuaikan dengan model yang digunakan
# ===============================
IMG_SIZE = (224, 224)


def preprocess_image(image):
    image = image.resize(IMG_SIZE)
    image = np.array(image)

    # Jika gambar grayscale menjadi RGB
    if len(image.shape) == 2:
        image = np.stack((image,) * 3, axis=-1)

    image = image.astype(np.float32) / 255.0
    image = np.expand_dims(image, axis=0)

    return image


@app.route("/")
def home():
    return jsonify({
        "message": "API berjalan"
    })


@app.route("/predict", methods=["POST"])
def predict():

    # Memastikan file dikirim
    if "image" not in request.files:
        return jsonify({
            "error": "Tidak ada file image yang dikirim"
        }), 400

    file = request.files["image"]

    if file.filename == "":
        return jsonify({
            "error": "File kosong"
        }), 400

    try:
        # Membaca gambar
        image = Image.open(file).convert("RGB")

        # Preprocessing
        image_array = preprocess_image(image)

        # Prediksi
        prediction = model.predict(image_array)

        predicted_index = np.argmax(prediction[0])

        predicted_class = class_names[predicted_index]

        info = disease_info.get(
            predicted_class,
            {
                "penyebab": "Informasi tidak tersedia",
                "solusi": []
            }
        )

        result = {
            "class": predicted_class,
            "confidence": round(float(np.max(prediction[0])) * 100, 2),
            "penyebab": info["penyebab"],
            "solusi": info["solusi"]
        }

        return jsonify(result)

    except Exception as e:
        return jsonify({
            "error": str(e)
        }), 500


if __name__ == "__main__":
    app.run(debug=True)