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



# ===============================
# INFORMASI PENYAKIT
# ===============================

disease_info = {

    "Daun_Karat_(Puccinia_Sorghi)": {

        "penyebab":
        "Karat daun pada tanaman jagung disebabkan oleh jamur Puccinia polysora yang menyerang bagian daun. Penyakit berkembang lebih cepat pada kondisi kelembapan udara dan tanah yang tinggi.",


        "solusi": [
            "Menggunakan bibit jagung yang tahan terhadap penyakit karat daun.",
            "Mengatur jadwal tanam pada periode Maret–April atau awal Oktober–November.",
            "Menjaga kelembapan tanah dan menghindari lahan terlalu basah.",
            "Melakukan pengairan ketika tanah mulai kering.",
            "Menggunakan fungisida sesuai rekomendasi."
        ]
    },


    "Daun_Hawar_(Exserohilum_Turcicum)": {


        "penyebab":
        "Hawar daun disebabkan oleh jamur Exserohilum turcicum yang menyerang jaringan daun. Penyakit berkembang pada lingkungan lembap dengan curah hujan tinggi.",


        "solusi": [
            "Menggunakan varietas jagung tahan hawar daun.",
            "Melakukan penanaman pada waktu yang sesuai.",
            "Mengatur jarak tanam agar sirkulasi udara baik.",
            "Mengatur sistem pengairan.",
            "Menghilangkan daun yang terinfeksi."
        ]

    },


    "Daun_Bulai_(Genus_Peronosclerospora)": {


        "penyebab":
        "Penyakit bulai disebabkan oleh patogen Peronosclerospora maydis yang menyerang tanaman terutama fase awal pertumbuhan.",


        "solusi": [
            "Menggunakan bibit tahan penyakit bulai.",
            "Melakukan perlakuan benih sebelum tanam.",
            "Menjaga kelembapan tanah.",
            "Melakukan pengairan ketika tanah mulai kering."
        ]

    },


    "Daun_Sehat_(Zea_Mays)": {


        "penyebab":
        "Daun sehat menunjukkan tanaman memperoleh nutrisi, air, dan cahaya yang cukup serta tidak mengalami serangan penyakit.",


        "solusi": [
            "Menggunakan bibit berkualitas.",
            "Memberikan pupuk sesuai kebutuhan.",
            "Menjaga kelembapan tanah stabil.",
            "Melakukan pemantauan tanaman rutin."
        ]

    }

}



# ===============================
# LOAD MODEL
# ===============================

model = load_model(MODEL_PATH)
with open(CLASS_NAMES_PATH, "r") as f:
    class_names = json.load(f)

# ===============================
# UKURAN INPUT MODEL
# ===============================
IMG_SIZE = (224,224)
def preprocess_image(image):
    image = image.resize(IMG_SIZE)
    image = np.array(image)
    if len(image.shape) == 2:
        image = np.stack(
            (image,) * 3,
            axis=-1
        )
    image = image.astype(np.float32) / 255.0
    image = np.expand_dims(
        image,
        axis=0
    )
    return image
# ===============================
# HOME
# ===============================
@app.route("/")
def home():
    return jsonify({
        "message": "API berjalan"
    })

# ===============================
# PREDICT
# ===============================
@app.route("/predict", methods=["POST"])
def predict():

    if "image" not in request.files:
        return jsonify({
            "error":"Tidak ada file image yang dikirim"
        }),400
    file = request.files["image"]
    if file.filename == "":
        return jsonify({
            "error":"File kosong"
        }),400
    try:
        image = Image.open(file).convert("RGB")
        image_array = preprocess_image(image)
        prediction = model.predict(image_array)
        predicted_index = np.argmax(prediction[0])
        predicted_class = class_names[predicted_index]
        confidence = float(
            np.max(prediction[0])
        ) * 100
        
        # ===============================
        # CEK VALIDASI KELAS
        # ===============================
        if (
            predicted_class not in disease_info
            or confidence < 70
        ):
            result = {
                "class":
                "Kelas tidak diketahui",
                "confidence":
                round(confidence,2),
                "penyebab":
                "Gambar tidak termasuk dalam kelas daun jagung yang tersedia.",
                "solusi":
                [

                "Gunakan gambar daun jagung yang jelas.",
                "Pastikan objek adalah daun jagung.",
                "Gunakan kelas Karat Daun, Hawar Daun, Bulai, atau Daun Sehat."
                ]
            }
        else:
            info = disease_info[predicted_class]
            result = {
                "class":
                predicted_class,
                "confidence":
                round(confidence,2),
                "penyebab":
                info["penyebab"],
                "solusi":
                info["solusi"]
            }
        return jsonify(result)
    except Exception as e:
        return jsonify({
            "error":str(e)
        }),500
# ===============================
# RUN SERVER
# ===============================
if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=5000,
        debug=True
    )