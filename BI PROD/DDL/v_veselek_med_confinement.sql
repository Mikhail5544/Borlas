create or replace force view v_veselek_med_confinement as
select a."AS_ASSURED_ID",a."UNDERWRITING_NOTE",a."ASSURED_MEDICAL_EXAM_ID",a."ROST",a."VES",a."PULS",a."EKG",a."МЕ",a."HIV",a."AD1",a."AD2",a."AD3",a."URINALYSIS",a."KROV",a."OTHER",
decode(nvl(to_number(rost),0),0,0,round(nvl(to_number(ves),0)/((to_number(rost)*to_number(rost))/10000),0)) bmi
 from
(
select assd.AS_ASSURED_ID, asme.UNDERWRITING_NOTE, ASSURED_MEDICAL_EXAM_ID,
INS.PKG_XX_AS_ASSURED.get_medical_result ('Рост', asme.ASSURED_MEDICAL_EXAM_ID) rost,
INS.PKG_XX_AS_ASSURED.get_medical_result ('Вес', asme.ASSURED_MEDICAL_EXAM_ID) ves,
INS.PKG_XX_AS_ASSURED.get_medical_result ('Пульс', asme.ASSURED_MEDICAL_EXAM_ID) puls,
INS.PKG_XX_AS_ASSURED.get_medical_result ('Стресс-ЭКГ', asme.ASSURED_MEDICAL_EXAM_ID) ekg,
INS.PKG_XX_AS_ASSURED.get_medical_result ('МЕ', asme.ASSURED_MEDICAL_EXAM_ID) МЕ,
INS.PKG_XX_AS_ASSURED.get_medical_result ('HIV', asme.ASSURED_MEDICAL_EXAM_ID) HIV,
INS.PKG_XX_AS_ASSURED.get_medical_result ('AD1', asme.ASSURED_MEDICAL_EXAM_ID) AD1,
INS.PKG_XX_AS_ASSURED.get_medical_result ('AD2', asme.ASSURED_MEDICAL_EXAM_ID) AD2,
INS.PKG_XX_AS_ASSURED.get_medical_result ('AD3', asme.ASSURED_MEDICAL_EXAM_ID) AD3,
INS.PKG_XX_AS_ASSURED.get_medical_result ('Urinalysis', asme.ASSURED_MEDICAL_EXAM_ID) Urinalysis,
INS.PKG_XX_AS_ASSURED.get_medical_result ('Клинический анализ крови', asme.ASSURED_MEDICAL_EXAM_ID) krov,
INS.PKG_XX_AS_ASSURED.get_medical_result ('Other:', asme.ASSURED_MEDICAL_EXAM_ID) other
from ASSURED_MEDICAL_EXAM asme, as_assured_docum assd
where asme.AS_ASSURED_DOCUM_ID = assd.AS_ASSURED_DOCUM_ID
) a;

