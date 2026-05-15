const fs = require('fs');

const hiPath = 'c:/Users/anshu/OneDrive/Desktop/WeddingZon/Weddingzon_Web_Final/client/public/locales/hi/common.json';
const paPath = 'c:/Users/anshu/OneDrive/Desktop/WeddingZon/Weddingzon_Web_Final/client/public/locales/pa/common.json';

const newOccupations = {
    "Businessman": "व्यवसायी",
    "MNC Job": "एमएनसी जॉब",
    "Private Job": "प्राइवेट जॉब",
    "Government Job": "सरकारी नौकरी",
    "NRI": "एनआरआई"
};

const matrimonySection = {
    "hero_title": "भारत का सर्वश्रेष्ठ वैवाहिक पोर्टल",
    "hero_subtitle": "वेडिंगज़ोन भारत का प्रमुख वैवाहिक मंच है, जो आपको अपना सही जीवनसाथी खोजने में मदद करने के लिए समर्पित है। विभिन्न समुदायों के हजारों सत्यापित प्रोफाइल के साथ, हम आपके प्यार की तलाश को सरल, सुरक्षित और सफल बनाते हैं।",
    "search_now": "अभी खोजें",
    "discover_title": "अपना सही मैच खोजें",
    "discover_subtitle": "हम उन लोगों को एक साथ लाते हैं जो समान मूल्यों और आकांक्षाओं को साझा करते हैं",
    "verified_profiles": "सत्यापित प्रोफाइल",
    "verified_desc": "हमारे सदस्यों के लिए सुरक्षित और वास्तविक अनुभव सुनिश्चित करने के लिए प्रत्येक प्रोफाइल को मैन्युअल रूप से सत्यापित किया जाता है।",
    "advanced_search": "अग्रिम खोज",
    "advanced_desc": "समुदाय, पेशे और बहुत कुछ के लिए हमारे विस्तृत फिल्टर के साथ वही खोजें जो आप ढूंढ रहे हैं।",
    "secure_platform": "सुरक्षित प्लेटफॉर्म",
    "secure_desc": "आपकी गोपनीयता हमारी प्राथमिकता है। आसानी से नियंत्रित करें कि आपकी तस्वीरें और संपर्क विवरण कौन देखता है।",
    "testimonials_title": "प्रशंसापत्र",
    "found_on_weddingzon": "वेडिंगज़ोन पर मिला",
    "testimonial_text": "वेडिंगज़ोन ने हमारी शादी की योजना बनाना बहुत आसान बना दिया। हमें सजावट, भोजन और मेकअप के लिए भरोसेमंद विक्रेता मिले, और हमें सब कुछ बहुत पसंद आया। वास्तव में एक शानदार अनुभव - अपने बड़े दिन की योजना बनाने वाले किसी भी जोड़े के लिए अत्यधिक अनुशंसित!"
};

const paOccupations = {
    "Businessman": "ਕਾਰੋਬਾਰੀ",
    "MNC Job": "MNC ਨੌਕਰੀ",
    "Private Job": "ਪ੍ਰਾਈਵੇਟ ਨੌਕਰੀ",
    "Government Job": "ਸਰਕਾਰੀ ਨੌਕਰੀ",
    "NRI": "ਐਨਆਰਆਈ"
};

const paMatrimonySection = {
    "hero_title": "ਭਾਰਤ ਦਾ ਸਭ ਤੋਂ ਵਧੀਆ ਮੈਟ੍ਰੀਮੋਨੀਅਲ ਪੋਰਟਲ",
    "hero_subtitle": "ਵੇਡਿੰਗਜ਼ੋਨ ਭਾਰਤ ਦਾ ਪ੍ਰਮੁੱਖ ਮੈਟ੍ਰੀਮੋਨੀਅਲ ਪਲੇਟਫਾਰਮ ਹੈ, ਜੋ ਤੁਹਾਡੇ ਸੰਪੂਰਨ ਜੀਵਨ ਸਾਥੀ ਨੂੰ ਲੱਭਣ ਵਿੱਚ ਤੁਹਾਡੀ ਮਦਦ ਕਰਨ ਲਈ ਸਮਰਪਿਤ ਹੈ। ਵੱਖ-ਵੱਖ ਭਾਈਚਾਰਿਆਂ ਦੇ ਹਜ਼ਾਰਾਂ ਪ੍ਰਮਾਣਿਤ ਪ੍ਰੋਫਾਈਲਾਂ ਦੇ ਨਾਲ, ਅਸੀਂ ਤੁਹਾਡੀ ਪਿਆਰ ਦੀ ਖੋਜ ਨੂੰ ਸਰਲ, ਸੁਰੱਖਿਅਤ ਅਤੇ ਸਫਲ ਬਣਾਉਂਦੇ ਹਾਂ।",
    "search_now": "ਹੁਣੇ ਖੋਜੋ",
    "discover_title": "ਆਪਣਾ ਸੰਪੂਰਨ ਮੈਚ ਲੱਭੋ",
    "discover_subtitle": "ਅਸੀਂ ਉਨ੍ਹਾਂ ਲੋਕਾਂ ਨੂੰ ਇਕੱਠੇ ਕਰਦੇ ਹਾਂ ਜੋ ਸਮਾਨ ਮੁੱਲਾਂ ਅਤੇ ਇੱਛਾਵਾਂ ਨੂੰ ਸਾਂਝਾ ਕਰਦੇ ਹਨ",
    "verified_profiles": "ਪ੍ਰਮਾਣਿਤ ਪ੍ਰੋਫਾਈਲ",
    "verified_desc": "ਸਾਡੇ ਮੈਂਬਰਾਂ ਲਈ ਸੁਰੱਖਿਅਤ ਅਤੇ ਅਸਲ ਅਨੁਭਵ ਯਕੀਨੀ ਬਣਾਉਣ ਲਈ ਹਰ ਪ੍ਰੋਫਾਈਲ ਨੂੰ ਮੈਨੂਅਲ ਰੂਪ ਵਿੱਚ ਪ੍ਰਮਾਣਿਤ ਕੀਤਾ ਜਾਂਦਾ ਹੈ।",
    "advanced_search": "ਐਡਵਾਂਸਡ ਖੋਜ",
    "advanced_desc": "ਭਾਈਚਾਰੇ, ਪੇਸ਼ੇ ਅਤੇ ਹੋਰ ਬਹੁਤ ਕੁਝ ਲਈ ਸਾਡੇ ਵਿਸਤ੍ਰਿਤ ਫਿਲਟਰਾਂ ਨਾਲ ਉਹੀ ਲੱਭੋ ਜਿਸ ਦੀ ਤੁਸੀਂ ਭਾਲ ਕਰ ਰਹੇ ਹੋ।",
    "secure_platform": "ਸੁਰੱਖਿਅਤ ਪਲੇਟਫਾਰਮ",
    "secure_desc": "ਤੁਹਾਡੀ ਪ੍ਰਾਈਵੇਸੀ ਸਾਡੀ ਤਰਜੀਹ ਹੈ। ਆਸਾਨੀ ਨਾਲ ਕੰਟਰੋਲ ਕਰੋ ਕਿ ਤੁਹਾਡੀਆਂ ਫੋਟੋਆਂ ਅਤੇ ਸੰਪਰਕ ਵੇਰਵੇ ਕੌਣ ਦੇਖਦਾ ਹੈ।",
    "testimonials_title": "ਪ੍ਰਸ਼ੰਸਾ ਪੱਤਰ",
    "found_on_weddingzon": "ਵੇਡਿੰਗਜ਼ੋਨ 'ਤੇ ਮਿਲਿਆ",
    "testimonial_text": "ਵੇਡਿੰਗਜ਼ੋਨ ਨੇ ਸਾਡੇ ਵਿਆਹ ਦੀ ਯੋਜਨਾ ਬਣਾਉਣਾ ਬਹੁਤ ਸੌਖਾ ਬਣਾ ਦਿੱਤਾ ਹੈ। ਸਾਨੂੰ ਸਜਾਵਟ, ਭੋਜਨ ਅਤੇ ਮੇਕਅਪ ਲਈ ਭਰੋਸੇਮੰਦ ਵਿਕਰੇਤਾ ਮਿਲੇ, ਅਤੇ ਅਸੀਂ ਸਭ ਕੁਝ ਬਹੁਤ ਪਸੰਦ ਕੀਤਾ। ਸੱਚਮੁੱਚ ਇੱਕ ਵਧੀਆ ਅਨੁਭਵ - ਆਪਣੇ ਵੱਡੇ ਦਿਨ ਦੀ ਯੋਜਨਾ ਬਣਾਉਣ ਵਾਲੇ ਕਿਸੇ ਵੀ ਜੋੜੇ ਲਈ ਬਹੁਤ ਸਿਫਾਰਸ਼ ਕੀਤੀ ਜਾਂਦੀ ਹੈ!"
};

function updateJson(path, occupations, section) {
    const data = JSON.parse(fs.readFileSync(path, 'utf8'));
    
    // Add occupations
    if (data.data && data.data.occupation) {
        Object.assign(data.data.occupation, occupations);
    }
    
    // Add matrimony section
    data.matrimony = section;
    
    fs.writeFileSync(path, JSON.stringify(data, null, 4), 'utf8');
    console.log(`Updated ${path}`);
}

updateJson(hiPath, newOccupations, matrimonySection);
updateJson(paPath, paOccupations, paMatrimonySection);
