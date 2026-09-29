import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'models/institucion_model.dart';
import 'models/oferta_model.dart';

Future<void> seedData() async {
  final firestore = FirebaseFirestore.instance;

  final batch = firestore.batch();

  // --- UTN ---
  batch.set(
    firestore.collection('instituciones').doc('utn'),
    InstitucionModel(
      institucionUid: 'utn',
      nombre: 'UTN',
      descripcion:
          'La Universidad TecnolÃ³gica Nacional es una instituciÃ³n pÃºblica de educaciÃ³n superior dedicada a la formaciÃ³n de profesionales en ingenierÃ­a y afines.',
      direccion: 'Av. Madero 399',
      ciudad: 'Ciudad AutÃ³noma de Buenos Aires',
      provincia: 'CABA',
      telefono: '(011) 4867-7500',
      email: 'info@frba.utn.edu.ar',
      sitioWeb: 'https://frba.utn.edu.ar',
      logoURL: 'https://utn.edu.ar/images/logo-utn.png',
      logoAsset: 'assets/imagenes/instituciones/utn.jpg',
      logoContained: true,
      latitud: -34.6037,
      longitud: -58.3683,
      estado: 'aprobada',
      createdAt: DateTime(2025, 1, 15),
    ).toMap(),
    SetOptions(merge: false),
  );

  final ofertas = [
    OfertaModel(
      ofertaId: 'oferta_utn_1',
      institucionUid: 'utn',
      nombre: 'Analista de Sistemas',
      descripcion:
          'FormaciÃ³n integral en anÃ¡lisis, diseÃ±o e implementaciÃ³n de sistemas informÃ¡ticos. Incluye prÃ¡cticas profesionalizantes en empresas del sector.',
      area: 'TecnologÃ­a',
      nivel: 'Terciario',
      duracionAnios: 3,
      modalidad: 'Presencial',
      salidaLaboral: 'Analista funcional, desarrollador, consultor TI',
      requisitos: 'Secundario completo',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 5, 10),
    ),
    OfertaModel(
      ofertaId: 'oferta_utn_2',
      institucionUid: 'utn',
      nombre: 'IngenierÃ­a en Sistemas',
      descripcion:
          'Carrera de grado con enfoque en desarrollo de software, gestiÃ³n de proyectos tecnolÃ³gicos y arquitectura de sistemas.',
      area: 'TecnologÃ­a',
      nivel: 'Universitario',
      duracionAnios: 5,
      modalidad: 'Presencial',
      salidaLaboral: 'Ingeniero de software, arquitecto de sistemas, CTO',
      requisitos: 'Secundario completo. Curso de ingreso obligatorio.',
      tag: 'FECHAS IMPORTANTES',
      aprobada: true,
      createdAt: DateTime(2026, 5, 8),
    ),
    OfertaModel(
      ofertaId: 'oferta_utn_3',
      institucionUid: 'utn',
      nombre: 'Tecnicatura en ProgramaciÃ³n',
      descripcion:
          'Carrera de formaciÃ³n rÃ¡pida en desarrollo de software, bases de datos y aplicaciones web. 100% orientada a la inserciÃ³n laboral.',
      area: 'TecnologÃ­a',
      nivel: 'Terciario',
      duracionAnios: 2,
      modalidad: 'Presencial',
      salidaLaboral: 'Programador junior, desarrollador web, tester QA',
      requisitos: 'Secundario completo. No requiere experiencia previa.',
      tag: 'NUEVO',
      aprobada: true,
      createdAt: DateTime(2026, 5, 15),
    ),
    OfertaModel(
      ofertaId: 'oferta_utn_4',
      institucionUid: 'utn',
      nombre: 'IngenierÃ­a Civil',
      descripcion:
          'FormaciÃ³n en diseÃ±o, cÃ¡lculo y construcciÃ³n de obras civiles. Laboratorios equipados y convenios con empresas constructoras.',
      area: 'IngenierÃ­a',
      nivel: 'Universitario',
      duracionAnios: 5,
      modalidad: 'Presencial',
      salidaLaboral: 'Ingeniero civil, proyectista, gerente de obra',
      requisitos: 'Secundario completo con orientaciÃ³n en exactas',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 5, 12),
    ),
    OfertaModel(
      ofertaId: 'oferta_utn_5',
      institucionUid: 'utn',
      nombre: 'IngenierÃ­a ElectrÃ³nica',
      descripcion:
          'Carrera orientada a sistemas embebidos, automatizaciÃ³n industrial y telecomunicaciones. Laboratorio de microcontroladores incluido.',
      area: 'IngenierÃ­a',
      nivel: 'Universitario',
      duracionAnios: 5,
      modalidad: 'Presencial',
      salidaLaboral:
          'Ingeniero electrÃ³nico, automatizador, diseÃ±ador de hardware',
      requisitos: 'Secundario completo',
      tag: 'BECAS',
      aprobada: true,
      createdAt: DateTime(2026, 5, 6),
    ),
    OfertaModel(
      ofertaId: 'oferta_utn_6',
      institucionUid: 'utn',
      nombre: 'Licenciatura en AdministraciÃ³n',
      descripcion:
          'FormaciÃ³n en gestiÃ³n empresarial, recursos humanos y finanzas. Modalidad cursada flexible con horarios rotativos.',
      area: 'AdministraciÃ³n',
      nivel: 'Universitario',
      duracionAnios: 4,
      modalidad: 'Presencial',
      salidaLaboral: 'Administrador de empresas, analista financiero, consultor',
      requisitos: 'Secundario completo',
      tag: 'FECHAS IMPORTANTES',
      aprobada: true,
      createdAt: DateTime(2026, 5, 3),
    ),
  ];

  // --- UNLP ---
  batch.set(
    firestore.collection('instituciones').doc('unlp'),
    InstitucionModel(
      institucionUid: 'unlp',
      nombre: 'UNLP',
      descripcion:
          'La Universidad Nacional de La Plata es una de las principales universidades pÃºblicas de Argentina, fundada en 1905.',
      direccion: 'Av. 7 NÂ° 776',
      ciudad: 'La Plata',
      provincia: 'Buenos Aires',
      telefono: '(0221) 423-6800',
      email: 'info@unlp.edu.ar',
      sitioWeb: 'https://www.unlp.edu.ar',
      logoURL: 'https://unlp.edu.ar/wp-content/uploads/2022/07/UNLP.png',
      logoAsset: 'assets/imagenes/instituciones/unlp.png',
      latitud: -34.9186,
      longitud: -57.9561,
      estado: 'aprobada',
      createdAt: DateTime(2025, 2, 1),
    ).toMap(),
    SetOptions(merge: false),
  );

  ofertas.addAll([
    OfertaModel(
      ofertaId: 'oferta_unlp_1',
      institucionUid: 'unlp',
      nombre: 'Licenciatura en Sistemas de InformaciÃ³n',
      descripcion:
          'FormaciÃ³n en anÃ¡lisis, diseÃ±o y gestiÃ³n de sistemas de informaciÃ³n. Enfoque en ingenierÃ­a de software y tecnologÃ­as emergentes.',
      area: 'TecnologÃ­a',
      nivel: 'Universitario',
      duracionAnios: 5,
      modalidad: 'Presencial',
      salidaLaboral: 'Licenciado en Sistemas, analista senior, tech lead',
      requisitos: 'Secundario completo.',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 4, 20),
    ),
    OfertaModel(
      ofertaId: 'oferta_unlp_2',
      institucionUid: 'unlp',
      nombre: 'AbogacÃ­a',
      descripcion:
          'Carrera clÃ¡sica de la UNLP con orientaciÃ³n en derecho pÃºblico y privado. ClÃ­nicas jurÃ­dicas para prÃ¡ctica profesional.',
      area: 'Derecho',
      nivel: 'Universitario',
      duracionAnios: 5,
      modalidad: 'Presencial',
      salidaLaboral: 'Abogado, procurador, mediador, asesor legal',
      requisitos: 'Secundario completo. Ingreso libre.',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 4, 18),
    ),
    OfertaModel(
      ofertaId: 'oferta_unlp_3',
      institucionUid: 'unlp',
      nombre: 'Medicina',
      descripcion:
          'FormaciÃ³n mÃ©dica con Ã©nfasis en salud pÃºblica y atenciÃ³n primaria. Hospital escuela con residencias propias.',
      area: 'Salud',
      nivel: 'Universitario',
      duracionAnios: 6,
      modalidad: 'Presencial',
      salidaLaboral: 'MÃ©dico general, especialista, investigador',
      requisitos: 'Secundario completo. Examen de admisiÃ³n.',
      tag: 'FECHAS IMPORTANTES',
      aprobada: true,
      createdAt: DateTime(2026, 4, 15),
    ),
    OfertaModel(
      ofertaId: 'oferta_unlp_4',
      institucionUid: 'unlp',
      nombre: 'Licenciatura en EconomÃ­a',
      descripcion:
          'AnÃ¡lisis econÃ³mico con base matemÃ¡tica sÃ³lida. Perspectiva de economÃ­a polÃ­tica y desarrollo regional.',
      area: 'EconomÃ­a',
      nivel: 'Universitario',
      duracionAnios: 4,
      modalidad: 'Presencial',
      salidaLaboral: 'Economista, analista financiero, investigador',
      requisitos: 'Secundario completo',
      tag: 'BECAS',
      aprobada: true,
      createdAt: DateTime(2026, 4, 12),
    ),
    OfertaModel(
      ofertaId: 'oferta_unlp_5',
      institucionUid: 'unlp',
      nombre: 'Arquitectura',
      descripcion:
          'DiseÃ±o arquitectÃ³nico con enfoque sustentable. Taller de diseÃ±o y Ð³Ð¾ÑÑƒÐ´ancies con proyectos reales.',
      area: 'Creativa',
      nivel: 'Universitario',
      duracionAnios: 5,
      modalidad: 'Presencial',
      salidaLaboral: 'Arquitecto, urbanista, paisajista, consultor',
      requisitos: 'Secundario completo. Examen de aptitud.',
      tag: 'NUEVO',
      aprobada: true,
      createdAt: DateTime(2026, 4, 10),
    ),
    OfertaModel(
      ofertaId: 'oferta_unlp_6',
      institucionUid: 'unlp',
      nombre: 'Licenciatura en Periodismo',
      descripcion:
          'FormaciÃ³n en periodismo escrito, audiovisual y digital. Taller de noticias y prÃ¡cticas en medios.',
      area: 'Creativa',
      nivel: 'Universitario',
      duracionAnios: 4,
      modalidad: 'Presencial',
      salidaLaboral: 'Periodista, community manager, editor, corresponsal',
      requisitos: 'Secundario completo. Ingreso libre.',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 4, 8),
    ),
  ]);

  // --- UNSAM ---
  batch.set(
    firestore.collection('instituciones').doc('unsam'),
    InstitucionModel(
      institucionUid: 'unsam',
      nombre: 'UNSAM',
      descripcion:
          'La Universidad Nacional de San MartÃ­n, fundada en 2009, se destaca por su enfoque interdisciplinario y producciÃ³n de conocimiento.',
      direccion: '25 de Mayo y Francia',
      ciudad: 'San MartÃ­n',
      provincia: 'Buenos Aires',
      telefono: '(011) 4006-1500',
      email: 'rrectorado@unsam.edu.ar',
      sitioWeb: 'https://www.unsam.edu.ar',
      logoURL: 'https://www.unsam.edu.ar/img/logo-UNSAM.png',
      logoAsset: 'assets/imagenes/instituciones/unsam.png',
      logoContained: true,
      latitud: -34.5746,
      longitud: -58.5144,
      estado: 'aprobada',
      createdAt: DateTime(2025, 2, 15),
    ).toMap(),
    SetOptions(merge: false),
  );

  ofertas.addAll([
    OfertaModel(
      ofertaId: 'oferta_unsam_1',
      institucionUid: 'unsam',
      nombre: 'Tecnicatura en ProducciÃ³n Audiovisual',
      descripcion:
          'FormaciÃ³n en cine, televisiÃ³n y producciÃ³n digital. Equipamiento profesional y profesores del sector.',
      area: 'Creativa',
      nivel: 'Terciario',
      duracionAnios: 3,
      modalidad: 'Presencial',
      salidaLaboral:
          'Director, productor, editor, camarÃ³grafo, sonidista',
      requisitos: 'Secundario completo. Portafolio recomendado.',
      tag: 'NUEVO',
      aprobada: true,
      createdAt: DateTime(2026, 3, 25),
    ),
    OfertaModel(
      ofertaId: 'oferta_unsam_2',
      institucionUid: 'unsam',
      nombre: 'Licenciatura en BiotecnologÃ­a',
      descripcion:
          'Carrera interdisciplinaria que combina biologÃ­a molecular, quÃ­mica y bioinformÃ¡tica. Laboratorios de Ãºltima generaciÃ³n.',
      area: 'Salud',
      nivel: 'Universitario',
      duracionAnios: 5,
      modalidad: 'Presencial',
      salidaLaboral:
          'BiotecnÃ³logo, investigador, analista en laboratorio',
      requisitos: 'Secundario completo. OrientaciÃ³n en ciencias naturales.',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 3, 20),
    ),
    OfertaModel(
      ofertaId: 'oferta_unsam_3',
      institucionUid: 'unsam',
      nombre: 'Tecnicatura en ProgramaciÃ³n',
      descripcion:
          'Desarrollo de software con foco en buenas prÃ¡cticas, testing y metodologÃ­as Ã¡giles. Proyectos grupales reales.',
      area: 'TecnologÃ­a',
      nivel: 'Terciario',
      duracionAnios: 2,
      modalidad: 'Presencial',
      salidaLaboral: 'Programador, desarrollador web y mÃ³vil',
      requisitos: 'Secundario completo',
      tag: 'BECAS',
      aprobada: true,
      createdAt: DateTime(2026, 3, 18),
    ),
    OfertaModel(
      ofertaId: 'oferta_unsam_4',
      institucionUid: 'unsam',
      nombre: 'Licenciatura en Relaciones Internacionales',
      descripcion:
          'AnÃ¡lisis de la polÃ­tica internacional, diplomacia y comercio exterior. Simulaciones de negociaciÃ³n y Model ONU.',
      area: 'Ciencias Sociales',
      nivel: 'Universitario',
      duracionAnios: 4,
      modalidad: 'Presencial',
      salidaLaboral:
          'Relacionista internacional, diplomÃ¡tico, analista polÃ­tico',
      requisitos: 'Secundario completo',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 3, 15),
    ),
    OfertaModel(
      ofertaId: 'oferta_unsam_5',
      institucionUid: 'unsam',
      nombre: 'Licenciatura en SociologÃ­a',
      descripcion:
          'Estudio de la sociedad contemporÃ¡nea, procesos sociales y metodologÃ­a de investigaciÃ³n cualitativa y cuantitativa.',
      area: 'Ciencias Sociales',
      nivel: 'Universitario',
      duracionAnios: 4,
      modalidad: 'Presencial',
      salidaLaboral: 'SociÃ³logo, investigador, consultor social',
      requisitos: 'Secundario completo',
      tag: 'FECHAS IMPORTANTES',
      aprobada: true,
      createdAt: DateTime(2026, 3, 12),
    ),
    OfertaModel(
      ofertaId: 'oferta_unsam_6',
      institucionUid: 'unsam',
      nombre: 'Tecnicatura en EnergÃ­as Renovables',
      descripcion:
          'FormaciÃ³n en instalaciÃ³n y mantenimiento de sistemas de energÃ­a solar, eÃ³lica y biomasa. PrÃ¡cticas en plantas piloto.',
      area: 'IngenierÃ­a',
      nivel: 'Terciario',
      duracionAnios: 2,
      modalidad: 'Presencial',
      salidaLaboral:
          'TÃ©cnico en energÃ­as renovables, instalador solar, consultor energÃ©tico',
      requisitos: 'Secundario completo',
      tag: 'NUEVO',
      aprobada: true,
      createdAt: DateTime(2026, 3, 10),
    ),
  ]);

  // --- UNQ ---
  batch.set(
    firestore.collection('instituciones').doc('unq'),
    InstitucionModel(
      institucionUid: 'unq',
      nombre: 'UNQ',
      descripcion:
          'La Universidad Nacional de Quilmes es una universidad pÃºblica que se destaca por su compromiso con la inclusiÃ³n social y la innovaciÃ³n pedagÃ³gica.',
      direccion: 'Roque SÃ¡enz PeÃ±a 352',
      ciudad: 'Bernal',
      provincia: 'Buenos Aires',
      telefono: '(011) 4365-7100',
      email: 'info@unq.edu.ar',
      sitioWeb: 'https://www.unq.edu.ar',
      logoURL: 'https://www.unq.edu.ar/wp-content/uploads/2022/11/LOGO-UNQ.png',
      logoAsset: 'assets/imagenes/instituciones/unq.png',
      logoContained: true,
      latitud: -34.7078,
      longitud: -58.2811,
      estado: 'aprobada',
      createdAt: DateTime(2025, 3, 1),
    ).toMap(),
    SetOptions(merge: false),
  );

  ofertas.addAll([
    OfertaModel(
      ofertaId: 'oferta_unq_1',
      institucionUid: 'unq',
      nombre: 'Licenciatura en SociologÃ­a',
      descripcion:
          'Carrera de referencia en sociologÃ­a con Ã©nfasis en estudios urbanos y polÃ­ticas pÃºblicas. InvestigaciÃ³n aplicada.',
      area: 'Ciencias Sociales',
      nivel: 'Universitario',
      duracionAnios: 4,
      modalidad: 'Presencial',
      salidaLaboral: 'SociÃ³logo, analista de polÃ­ticas pÃºblicas',
      requisitos: 'Secundario completo. Ingreso libre.',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 4, 5),
    ),
    OfertaModel(
      ofertaId: 'oferta_unq_2',
      institucionUid: 'unq',
      nombre: 'Tecnicatura en RegulaciÃ³n y GestiÃ³n de Servicios PÃºblicos',
      descripcion:
          'FormaciÃ³n Ãºnica en regulaciÃ³n de servicios pÃºblicos: agua, energÃ­a, transporte y telecomunicaciones.',
      area: 'AdministraciÃ³n',
      nivel: 'Terciario',
      duracionAnios: 3,
      modalidad: 'Presencial',
      salidaLaboral:
          'TÃ©cnico regulador, consultor en servicios pÃºblicos',
      requisitos: 'Secundario completo',
      tag: 'NUEVO',
      aprobada: true,
      createdAt: DateTime(2026, 4, 3),
    ),
    OfertaModel(
      ofertaId: 'oferta_unq_3',
      institucionUid: 'unq',
      nombre: 'Licenciatura en EconomÃ­a',
      descripcion:
          'EconomÃ­a con perspectiva crÃ­tica y enfoque en desarrollo productivo regional. Seminarios con especialistas.',
      area: 'EconomÃ­a',
      nivel: 'Universitario',
      duracionAnios: 4,
      modalidad: 'Presencial',
      salidaLaboral: 'Economista, analista de riesgo, funcionario pÃºblico',
      requisitos: 'Secundario completo',
      tag: 'BECAS',
      aprobada: true,
      createdAt: DateTime(2026, 4, 1),
    ),
    OfertaModel(
      ofertaId: 'oferta_unq_4',
      institucionUid: 'unq',
      nombre: 'Licenciatura en DiseÃ±o',
      descripcion:
          'DiseÃ±o grÃ¡fico, industrial y de interacciÃ³n. Taller con proyectos reales para empresas y organismos pÃºblicos.',
      area: 'Creativa',
      nivel: 'Universitario',
      duracionAnios: 4,
      modalidad: 'Presencial',
      salidaLaboral: 'DiseÃ±ador grÃ¡fico, UX designer, director de arte',
      requisitos: 'Secundario completo. Muestra de trabajos.',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 3, 28),
    ),
    OfertaModel(
      ofertaId: 'oferta_unq_5',
      institucionUid: 'unq',
      nombre: 'Tecnicatura en ProducciÃ³n Musical y Sonido',
      descripcion:
          'FormaciÃ³n en grabaciÃ³n, mezcla y producciÃ³n musical. Estudio de grabaciÃ³n con equipamiento profesional.',
      area: 'Creativa',
      nivel: 'Terciario',
      duracionAnios: 2,
      modalidad: 'Presencial',
      salidaLaboral: 'Productor musical, ingeniero de sonido, sonidista',
      requisitos: 'Secundario completo. Entrevista motivacional.',
      tag: 'NUEVO',
      aprobada: true,
      createdAt: DateTime(2026, 3, 25),
    ),
    OfertaModel(
      ofertaId: 'oferta_unq_6',
      institucionUid: 'unq',
      nombre: 'Licenciatura en PolÃ­tica y GestiÃ³n Deportiva',
      descripcion:
          'GestiÃ³n de organizaciones deportivas, marketing deportivo y polÃ­ticas pÃºblicas del deporte. PrÃ¡cticas en clubes y federaciones.',
      area: 'AdministraciÃ³n',
      nivel: 'Universitario',
      duracionAnios: 4,
      modalidad: 'Presencial',
      salidaLaboral:
          'Gestor deportivo, director de.entidades, asesor de polÃ­ticas deportivas',
      requisitos: 'Secundario completo',
      tag: 'FECHAS IMPORTANTES',
      aprobada: true,
      createdAt: DateTime(2026, 3, 22),
    ),
  ]);

  // --- UNICEN ---
  batch.set(
    firestore.collection('instituciones').doc('unicen'),
    InstitucionModel(
      institucionUid: 'unicen',
      nombre: 'UNICEN',
      descripcion:
          'La Universidad Nacional del Centro de la Provincia de Buenos Aires, con sedes en Tandil, Azul y OlavarrÃ­a, ofrece formaciÃ³n de calidad.',
      direccion: 'Gral. Pinto 399',
      ciudad: 'Tandil',
      provincia: 'Buenos Aires',
      telefono: '(0249) 438-5600',
      email: 'info@unicen.edu.ar',
      sitioWeb: 'https://www.unicen.edu.ar',
      logoURL: 'https://www.unicen.edu.ar/sites/all/themes/unicen/images/logo-50.png',
      logoAsset: 'assets/imagenes/instituciones/unicen.jpg',
      logoContained: true,
      latitud: -37.3217,
      longitud: -59.1332,
      estado: 'aprobada',
      createdAt: DateTime(2025, 3, 15),
    ).toMap(),
    SetOptions(merge: false),
  );

  ofertas.addAll([
    OfertaModel(
      ofertaId: 'oferta_unicen_1',
      institucionUid: 'unicen',
      nombre: 'Licenciatura en Ciencias de la ComputaciÃ³n',
      descripcion:
          'FormaciÃ³n teÃ³rica y prÃ¡ctica en computaciÃ³n. Algoritmos, inteligencia artificial y ciencia de datos.',
      area: 'TecnologÃ­a',
      nivel: 'Universitario',
      duracionAnios: 5,
      modalidad: 'Presencial',
      salidaLaboral: 'CientÃ­fico de datos, desarrollador, investigador',
      requisitos: 'Secundario completo. Examen de ingreso en exactas.',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 3, 30),
    ),
    OfertaModel(
      ofertaId: 'oferta_unicen_2',
      institucionUid: 'unicen',
      nombre: 'Tecnicatura en InstrumentaciÃ³n y Control',
      descripcion:
          'MediciÃ³n, instrumentaciÃ³n y control de procesos industriales. Laboratorios con equipamiento industrial real.',
      area: 'IngenierÃ­a',
      nivel: 'Terciario',
      duracionAnios: 3,
      modalidad: 'Presencial',
      salidaLaboral:
          'TÃ©cnico en instrumentaciÃ³n, control de procesos, automatizaciÃ³n',
      requisitos: 'Secundario completo. OrientaciÃ³n tÃ©cnica.',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 3, 28),
    ),
    OfertaModel(
      ofertaId: 'oferta_unicen_3',
      institucionUid: 'unicen',
      nombre: 'Licenciatura en Historia',
      descripcion:
          'Estudio de procesos histÃ³ricos argentinos, latinoamericanos y mundiales. Archivos y fuentes primarias.',
      area: 'Humanidades',
      nivel: 'Universitario',
      duracionAnios: 4,
      modalidad: 'Presencial',
      salidaLaboral: 'Historiador, docente, archivista, investigador',
      requisitos: 'Secundario completo',
      tag: 'BECAS',
      aprobada: true,
      createdAt: DateTime(2026, 3, 25),
    ),
    OfertaModel(
      ofertaId: 'oferta_unicen_4',
      institucionUid: 'unicen',
      nombre: 'Tecnicatura en GestiÃ³n Ambiental',
      descripcion:
          'GestiÃ³n de residuos, auditorÃ­a ambiental y desarrollo sustentable. Trabajo de campo en parques naturales.',
      area: 'Ciencias Ambientales',
      nivel: 'Terciario',
      duracionAnios: 2,
      modalidad: 'Presencial',
      salidaLaboral:
          'TÃ©cnico ambiental, auditor, gestor de residuos',
      requisitos: 'Secundario completo',
      tag: 'NUEVO',
      aprobada: true,
      createdAt: DateTime(2026, 3, 22),
    ),
    OfertaModel(
      ofertaId: 'oferta_unicen_5',
      institucionUid: 'unicen',
      nombre: 'Licenciatura en Turismo',
      descripcion:
          'GestiÃ³n turÃ­stica, hotelerÃ­a y desarrollo de destinos. PrÃ¡cticas en hoteles y agencias de viajes de Tandil.',
      area: 'AdministraciÃ³n',
      nivel: 'Universitario',
      duracionAnios: 4,
      modalidad: 'Presencial',
      salidaLaboral:
          'Gestor turÃ­stico, recepcionista, guÃ­a, emprendedor turÃ­stico',
      requisitos: 'Secundario completo',
      tag: 'FECHAS IMPORTANTES',
      aprobada: true,
      createdAt: DateTime(2026, 3, 20),
    ),
    OfertaModel(
      ofertaId: 'oferta_unicen_6',
      institucionUid: 'unicen',
      nombre: 'IngenierÃ­a en ElectrÃ³nica',
      descripcion:
          'DiseÃ±o de circuitos, sistemas embebidos y robÃ³tica. ElectrÃ³nica aplicada a la industria y la salud.',
      area: 'IngenierÃ­a',
      nivel: 'Universitario',
      duracionAnios: 5,
      modalidad: 'Presencial',
      salidaLaboral:
          'Ingeniero electrÃ³nico, diseÃ±ador de hardware, investigador',
      requisitos: 'Secundario completo con orientaciÃ³n en exactas',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 3, 18),
    ),
  ]);

  // --- UNMDP ---
  batch.set(
    firestore.collection('instituciones').doc('unmdp'),
    InstitucionModel(
      institucionUid: 'unmdp',
      nombre: 'UNMDP',
      descripcion:
          'La Universidad Nacional de Mar del Plata es referente en estudios marinos, turismo y ciencias del mar.',
      direccion: 'Diagonal J. B. Alberdi 2695',
      ciudad: 'Mar del Plata',
      provincia: 'Buenos Aires',
      telefono: '(0223) 492-1705',
      email: 'info@mdp.edu.ar',
      sitioWeb: 'https://www.mdp.edu.ar',
      logoURL: 'https://www.mdp.edu.ar/templates/unmdp/iconos/512.png',
      logoAsset: 'assets/imagenes/instituciones/unmdp.png',
      latitud: -38.0055,
      longitud: -57.5426,
      estado: 'aprobada',
      createdAt: DateTime(2025, 4, 1),
    ).toMap(),
    SetOptions(merge: false),
  );

  ofertas.addAll([
    OfertaModel(
      ofertaId: 'oferta_unmdp_1',
      institucionUid: 'unmdp',
      nombre: 'Licenciatura en Ciencias del Mar',
      descripcion:
          'FormaciÃ³n en biologÃ­a marina, oceanografÃ­a y gestiÃ³n de recursos acuÃ¡ticos. PrÃ¡cticas en el Instituto de BiologÃ­a Marina.',
      area: 'Ciencias Ambientales',
      nivel: 'Universitario',
      duracionAnios: 5,
      modalidad: 'Presencial',
      salidaLaboral:
          'CientÃ­fico marino, biÃ³logo pesquero, gestor ambiental',
      requisitos: 'Secundario completo. OrientaciÃ³n en ciencias naturales.',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 4, 10),
    ),
    OfertaModel(
      ofertaId: 'oferta_unmdp_2',
      institucionUid: 'unmdp',
      nombre: 'Tecnicatura en EnfermerÃ­a',
      descripcion:
          'FormaciÃ³n en cuidados enfermeros con rotaciones en hospitales pÃºblicos. Enfoque en salud comunitaria.',
      area: 'Salud',
      nivel: 'Terciario',
      duracionAnios: 3,
      modalidad: 'Presencial',
      salidaLaboral: 'Enfermero, enfermero jefe, gestor de salud',
      requisitos: 'Secundario completo. Examen de ingreso.',
      tag: 'FECHAS IMPORTANTES',
      aprobada: true,
      createdAt: DateTime(2026, 4, 8),
    ),
    OfertaModel(
      ofertaId: 'oferta_unmdp_3',
      institucionUid: 'unmdp',
      nombre: 'Licenciatura en GeografÃ­a',
      descripcion:
          'Estudio del territorio, SIG y cartografÃ­a. Trabajo de campo en la costa atlÃ¡ntica y regiones pampeanas.',
      area: 'Ciencias Sociales',
      nivel: 'Universitario',
      duracionAnios: 4,
      modalidad: 'Presencial',
      salidaLaboral:
          'GeÃ³grafo, analista SIG, planificador territorial',
      requisitos: 'Secundario completo',
      tag: 'BECAS',
      aprobada: true,
      createdAt: DateTime(2026, 4, 5),
    ),
    OfertaModel(
      ofertaId: 'oferta_unmdp_4',
      institucionUid: 'unmdp',
      nombre: 'Tecnicatura en GastronomÃ­a',
      descripcion:
          'Cocina argentina e internacional, pastelerÃ­a y gestiÃ³n de gastronomÃ­a. PrÃ¡cticas en restaurantes de Mar del Plata.',
      area: 'Creativa',
      nivel: 'Terciario',
      duracionAnios: 2,
      modalidad: 'Presencial',
      salidaLaboral: 'Chef, pastelero, consultor gastronÃ³mico',
      requisitos: 'Secundario completo. Entrevista personal.',
      tag: 'NUEVO',
      aprobada: true,
      createdAt: DateTime(2026, 4, 3),
    ),
    OfertaModel(
      ofertaId: 'oferta_unmdp_5',
      institucionUid: 'unmdp',
      nombre: 'Licenciatura en ComunicaciÃ³n',
      descripcion:
          'ComunicaciÃ³n social, periodismo digital y producciÃ³n de contenidos. Laboratorio de medios digitales.',
      area: 'Creativa',
      nivel: 'Universitario',
      duracionAnios: 4,
      modalidad: 'Presencial',
      salidaLaboral: 'Comunicador, periodista, productor de medios',
      requisitos: 'Secundario completo',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 4, 1),
    ),
    OfertaModel(
      ofertaId: 'oferta_unmdp_6',
      institucionUid: 'unmdp',
      nombre: 'Licenciatura en EconomÃ­a',
      descripcion:
          'EconomÃ­a con foco en recursos naturales y turismo. AnÃ¡lisis econÃ³mico regional.',
      area: 'EconomÃ­a',
      nivel: 'Universitario',
      duracionAnios: 4,
      modalidad: 'Presencial',
      salidaLaboral: 'Economista, analista, funcionario pÃºblico',
      requisitos: 'Secundario completo',
      tag: 'BECAS',
      aprobada: true,
      createdAt: DateTime(2026, 3, 28),
    ),
  ]);

  // --- UNGS ---
  batch.set(
    firestore.collection('instituciones').doc('ungs'),
    InstitucionModel(
      institucionUid: 'ungs',
      nombre: 'UNGS',
      descripcion:
          'La Universidad Nacional de General Sarmiento, en Los Polvorines, se especializa en ciencias sociales, tecnologÃ­a y formaciÃ³n docente.',
      direccion: 'Juan MarÃ­a GutiÃ©rrez 1150',
      ciudad: 'Los Polvorines',
      provincia: 'Buenos Aires',
      telefono: '(011) 4469-7500',
      email: 'info@campus.ungs.edu.ar',
      sitioWeb: 'https://www.ungs.edu.ar',
      logoURL: 'https://www.ungs.edu.ar/wp-content/uploads/2024/06/logo_ungs_512.png',
      logoAsset: 'assets/imagenes/instituciones/ungs.png',
      fotoCampus: 'assets/imagenes/campus/ungs.jpg',
      latitud: -34.5267,
      longitud: -58.6988,
      estado: 'aprobada',
      createdAt: DateTime(2025, 4, 15),
    ).toMap(),
    SetOptions(merge: false),
  );

  ofertas.addAll([
    OfertaModel(
      ofertaId: 'oferta_ungs_1',
      institucionUid: 'ungs',
      nombre: 'Licenciatura en Urbanismo',
      descripcion:
          'PlanificaciÃ³n urbana, diseÃ±o de espacios pÃºblicos y gestiÃ³n municipal. Taller con proyectos para el GCBA.',
      area: 'Ciencias Sociales',
      nivel: 'Universitario',
      duracionAnios: 5,
      modalidad: 'Presencial',
      salidaLaboral: 'Urbanista, planificador, asesor municipal',
      requisitos: 'Secundario completo',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 4, 12),
    ),
    OfertaModel(
      ofertaId: 'oferta_ungs_2',
      institucionUid: 'ungs',
      nombre: 'Tecnicatura en MecatrÃ³nica',
      descripcion:
          'AutomatizaciÃ³n, robÃ³tica y sistemas mecatrÃ³nicos. Laboratorio con robots industriales y PLCs.',
      area: 'IngenierÃ­a',
      nivel: 'Terciario',
      duracionAnios: 3,
      modalidad: 'Presencial',
      salidaLaboral:
          'TÃ©cnico mecatrÃ³nico, automatizador, programador de PLCs',
      requisitos: 'Secundario completo. OrientaciÃ³n tÃ©cnica.',
      tag: 'NUEVO',
      aprobada: true,
      createdAt: DateTime(2026, 4, 10),
    ),
    OfertaModel(
      ofertaId: 'oferta_ungs_3',
      institucionUid: 'ungs',
      nombre: 'Licenciatura en Trabajo Social',
      descripcion:
          'FormaciÃ³n en intervenciÃ³n social, polÃ­ticas pÃºblicas y trabajo comunitario. PrÃ¡cticas en organizaciones sociales.',
      area: 'Ciencias Sociales',
      nivel: 'Universitario',
      duracionAnios: 4,
      modalidad: 'Presencial',
      salidaLaboral:
          'Trabajador social, asistente social, gestor de polÃ­ticas',
      requisitos: 'Secundario completo',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 4, 8),
    ),
    OfertaModel(
      ofertaId: 'oferta_ungs_4',
      institucionUid: 'ungs',
      nombre: 'Licenciatura en Ciencias PolÃ­ticas',
      descripcion:
          'AnÃ¡lisis polÃ­tico, gobierno y gestiÃ³n pÃºblica. Simulaciones de debate y Model ONU.',
      area: 'Ciencias Sociales',
      nivel: 'Universitario',
      duracionAnios: 4,
      modalidad: 'Presencial',
      salidaLaboral:
          'Cientista polÃ­tico, funcionario, asesor legislativo',
      requisitos: 'Secundario completo',
      tag: 'FECHAS IMPORTANTES',
      aprobada: true,
      createdAt: DateTime(2026, 4, 5),
    ),
    OfertaModel(
      ofertaId: 'oferta_ungs_5',
      institucionUid: 'ungs',
      nombre: 'Tecnicatura en ProgramaciÃ³n',
      descripcion:
          'Desarrollo de software con metodologÃ­as Ã¡giles. Frameworks modernos y buenas prÃ¡cticas.',
      area: 'TecnologÃ­a',
      nivel: 'Terciario',
      duracionAnios: 2,
      modalidad: 'Presencial',
      salidaLaboral: 'Programador, desarrollador web y mÃ³vil',
      requisitos: 'Secundario completo',
      tag: 'BECAS',
      aprobada: true,
      createdAt: DateTime(2026, 4, 3),
    ),
    OfertaModel(
      ofertaId: 'oferta_ungs_6',
      institucionUid: 'ungs',
      nombre: 'Licenciatura en DiseÃ±o Industrial',
      descripcion:
          'DiseÃ±o de productos industriales con enfoque en sustentabilidad. Taller con prototipado digital.',
      area: 'Creativa',
      nivel: 'Universitario',
      duracionAnios: 5,
      modalidad: 'Presencial',
      salidaLaboral: 'DiseÃ±ador industrial, prototipador, consultor',
      requisitos: 'Secundario completo. Examen de aptitud.',
      tag: 'NUEVO',
      aprobada: true,
      createdAt: DateTime(2026, 4, 1),
    ),
  ]);

  // --- UNLZ (Universidad Nacional de Lomas de Zamora) ---
  batch.set(
    firestore.collection('instituciones').doc('unlz'),
    InstitucionModel(
      institucionUid: 'unlz',
      nombre: 'UNLZ',
      descripcion:
          'La Universidad Nacional de Lomas de Zamora, en el sur del Gran Buenos Aires, ofrece carreras con fuerte compromiso social.',
      direccion: 'Camino de Cintura y Juan XXIII',
      ciudad: 'Lomas de Zamora',
      provincia: 'Buenos Aires',
      telefono: '(011) 4282-8045',
      email: 'info@unlz.edu.ar',
      sitioWeb: 'https://www.unlz.edu.ar',
      logoURL: 'https://www.unlz.edu.ar/wp-content/uploads/2023/12/unlz-logo-png.png',
      logoAsset: 'assets/imagenes/instituciones/unlz.png',
      logoContained: true,
      latitud: -34.7649,
      longitud: -58.3963,
      estado: 'aprobada',
      createdAt: DateTime(2025, 5, 1),
    ).toMap(),
    SetOptions(merge: false),
  );

  ofertas.addAll([
    OfertaModel(
      ofertaId: 'oferta_unlz_1',
      institucionUid: 'unlz',
      nombre: 'AbogacÃ­a',
      descripcion:
          'FormaciÃ³n en derecho con Ã©nfasis en derechos humanos y justicia social. ClÃ­nicas jurÃ­dicas en zonas vulnerables.',
      area: 'Derecho',
      nivel: 'Universitario',
      duracionAnios: 5,
      modalidad: 'Presencial',
      salidaLaboral: 'Abogado, defensor, mediador',
      requisitos: 'Secundario completo. Ingreso libre.',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 4, 15),
    ),
    OfertaModel(
      ofertaId: 'oferta_unlz_2',
      institucionUid: 'unlz',
      nombre: 'Licenciatura en Ciencias EconÃ³micas',
      descripcion:
          'EconomÃ­a, contabilidad y finanzas pÃºblicas. Enfoque en economÃ­a social y solidaria.',
      area: 'EconomÃ­a',
      nivel: 'Universitario',
      duracionAnios: 5,
      modalidad: 'Presencial',
      salidaLaboral: 'Economista, contador, auditor financiero',
      requisitos: 'Secundario completo',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 4, 12),
    ),
    OfertaModel(
      ofertaId: 'oferta_unlz_3',
      institucionUid: 'unlz',
      nombre: 'Licenciatura en ComunicaciÃ³n Social',
      descripcion:
          'Periodismo, comunicaciÃ³n institucional y medios digitales. ProducciÃ³n de contenido en la FM de la universidad.',
      area: 'Creativa',
      nivel: 'Universitario',
      duracionAnios: 4,
      modalidad: 'Presencial',
      salidaLaboral: 'Periodista, comunicador, productor de medios',
      requisitos: 'Secundario completo',
      tag: 'NUEVO',
      aprobada: true,
      createdAt: DateTime(2026, 4, 10),
    ),
    OfertaModel(
      ofertaId: 'oferta_unlz_4',
      institucionUid: 'unlz',
      nombre: 'Tecnicatura en Recursos Humanos',
      descripcion:
          'GestiÃ³n de personal, reclutamiento, capacitaciÃ³n y legislaciÃ³n laboral. PrÃ¡cticas en empresas del sur del GBA.',
      area: 'AdministraciÃ³n',
      nivel: 'Terciario',
      duracionAnios: 2,
      modalidad: 'Presencial',
      salidaLaboral:
          'TÃ©cnico en RRHH, selector de personal, capacitador',
      requisitos: 'Secundario completo',
      tag: 'FECHAS IMPORTANTES',
      aprobada: true,
      createdAt: DateTime(2026, 4, 8),
    ),
    OfertaModel(
      ofertaId: 'oferta_unlz_5',
      institucionUid: 'unlz',
      nombre: 'Licenciatura en EducaciÃ³n',
      descripcion:
          'FormaciÃ³n docente con enfoque en tecnologÃ­a educativa y pedagogÃ­a crÃ­tica. PrÃ¡cticas en escuelas del conurbano.',
      area: 'EducaciÃ³n',
      nivel: 'Universitario',
      duracionAnios: 4,
      modalidad: 'Presencial',
      salidaLaboral: 'Docente, pedagogo, diseÃ±ador curricular',
      requisitos: 'Secundario completo',
      tag: 'BECAS',
      aprobada: true,
      createdAt: DateTime(2026, 4, 5),
    ),
    OfertaModel(
      ofertaId: 'oferta_unlz_6',
      institucionUid: 'unlz',
      nombre: 'Tecnicatura en Desarrollo de Software',
      descripcion:
          'ProgramaciÃ³n web, mÃ³vil y bases de datos. Proyecto integrador con empresa real en el Ãºltimo semestre.',
      area: 'TecnologÃ­a',
      nivel: 'Terciario',
      duracionAnios: 2,
      modalidad: 'Presencial',
      salidaLaboral: 'Desarrollador, programador, tester',
      requisitos: 'Secundario completo. Examen de ingreso en lÃ³gica.',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 4, 3),
    ),
  ]);

  // --- UNPAZ (Universidad Nacional de JosÃ© C. Paz) ---
  batch.set(
    firestore.collection('instituciones').doc('unpaz'),
    InstitucionModel(
      institucionUid: 'unpaz',
      nombre: 'UNPAZ',
      descripcion:
          'La Universidad Nacional de JosÃ© Clemente Paz, fundada en 2009, es una universidad pÃºblica de acceso irrestricto con enfoque interdisciplinario y compromiso social.',
      direccion: 'Leandro N. Alem 4731',
      ciudad: 'JosÃ© C. Paz',
      provincia: 'Buenos Aires',
      telefono: '(02320) 649025',
      email: 'comunicacion@unpaz.edu.ar',
      sitioWeb: 'https://www.unpaz.edu.ar',
      logoURL: 'https://www.unpaz.edu.ar/sites/default/files/Logo%20Unpaz.png',
      logoAsset: 'assets/imagenes/instituciones/unpaz.png',
      logoContained: true,
      fotoCampus: 'assets/imagenes/campus/unpaz.jpg',
      latitud: -34.5204,
      longitud: -58.7456,
      estado: 'aprobada',
      createdAt: DateTime(2025, 6, 1),
    ).toMap(),
    SetOptions(merge: false),
  );

  // --- USAL e ISFDyT NÂ°35 ---
  for (final inst in institucionesNuevas()) {
    batch.set(
      firestore.collection('instituciones').doc(inst.institucionUid),
      inst.toMap(),
      SetOptions(merge: false),
    );
  }

  // --- ISFT 184 (Pilar) ---
  batch.set(
    firestore.collection('instituciones').doc('isft184'),
    InstitucionModel(
      institucionUid: 'isft184',
      nombre: 'ISFT NÂ°184',
      descripcion:
          'Instituto Superior de FormaciÃ³n TÃ©cnica NÂº 184 "Lic. Jorge Pugliese" de Pilar. MÃ¡s de 34 aÃ±os formando profesionales con tÃ­tulos de validez nacional.',
      direccion: 'Sanguinetti 521',
      ciudad: 'Pilar',
      provincia: 'Buenos Aires',
      telefono: '(0230) 443-5135',
      email: 'isft184oficial@gmail.com',
      sitioWeb: 'https://isft184.wixsite.com/inicio',
      logoURL: 'https://isft184-bue.infd.edu.ar/sitio/wp-content/uploads/2020/10/icono-184.jpg',
      logoAsset: 'assets/imagenes/instituciones/isft184.jpg',
      latitud: -34.4547,
      longitud: -58.9103,
      estado: 'aprobada',
      createdAt: DateTime(2025, 6, 1),
    ).toMap(),
    SetOptions(merge: false),
  );

  // --- ISFT 182 (San Miguel) ---
  batch.set(
    firestore.collection('instituciones').doc('isft182'),
    InstitucionModel(
      institucionUid: 'isft182',
      nombre: 'ISFT NÂ°182',
      descripcion:
          'Instituto Superior de FormaciÃ³n TÃ©cnica NÂº 182 "Nos Importa el MaÃ±ana" de San Miguel. Ofrece tecnicaturas en AnÃ¡lisis de Sistemas, EnfermerÃ­a, RRHH y mÃ¡s.',
      direccion: 'Rta. 8 y Avellaneda, Bo. Sgto. Cabral',
      ciudad: 'San Miguel',
      provincia: 'Buenos Aires',
      telefono: '(011) 4667-3993',
      email: '182informes@gmail.com',
      sitioWeb: 'https://isft182.edu.ar',
      logoURL: 'https://isft182-bue.infd.edu.ar/sitio/wp-content/uploads/2018/09/isft182_logo.png',
      logoAsset: 'assets/imagenes/instituciones/isft182.jpg',
      logoContained: true,
      latitud: -34.5348,
      longitud: -58.6941,
      estado: 'aprobada',
      createdAt: DateTime(2025, 6, 1),
    ).toMap(),
    SetOptions(merge: false),
  );

  // --- ISFT 234 (Malvinas Argentinas / Los Polvorines) ---
  batch.set(
    firestore.collection('instituciones').doc('isft234'),
    InstitucionModel(
      institucionUid: 'isft234',
      nombre: 'ISFT NÂ°234',
      descripcion:
          'Instituto Superior de FormaciÃ³n TÃ©cnica NÂº 234 de Malvinas Argentinas. Carreras bimodales con tÃ­tulos oficiales avalados por la DirecciÃ³n General de Cultura y EducaciÃ³n.',
      direccion: '25 de Mayo 3084',
      ciudad: 'Los Polvorines, Malvinas Argentinas',
      provincia: 'Buenos Aires',
      telefono: '(011) 4664-0000',
      email: 'isft234@gmail.com',
      sitioWeb: 'https://isft234.edu.ar',
      logoURL: 'https://isft234.edu.ar/wp-content/uploads/2021/11/INSTITUTO-SUPERIOR-234.png',
      logoAsset: 'assets/imagenes/instituciones/isft234.jpg',
      logoContained: true,
      latitud: -34.5200,
      longitud: -58.6950,
      estado: 'aprobada',
      createdAt: DateTime(2025, 6, 1),
    ).toMap(),
    SetOptions(merge: false),
  );

  // --- Ofertas de zona norte (1 por ISFT, sin carreras completas) ---
  ofertas.addAll([
    OfertaModel(
      ofertaId: 'oferta_isft184_1',
      institucionUid: 'isft184',
      nombre: 'Tecnicatura Superior en AdministraciÃ³n',
      descripcion:
          'FormaciÃ³n en gestiÃ³n empresarial, contabilidad y recursos humanos. TÃ­tulos de validez nacional.',
      area: 'AdministraciÃ³n',
      nivel: 'Terciario',
      duracionAnios: 3,
      modalidad: 'Presencial',
      salidaLaboral: 'Administrativo, analista contable, gestor',
      requisitos: 'Secundario completo',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 6, 1),
    ),
    OfertaModel(
      ofertaId: 'oferta_isft182_1',
      institucionUid: 'isft182',
      nombre: 'Tecnicatura Superior en AnÃ¡lisis de Sistemas',
      descripcion:
          'FormaciÃ³n en anÃ¡lisis, diseÃ±o e implementaciÃ³n de sistemas informÃ¡ticos. PrÃ¡cticas en empresas del sector.',
      area: 'TecnologÃ­a',
      nivel: 'Terciario',
      duracionAnios: 3,
      modalidad: 'Presencial',
      salidaLaboral: 'Analista funcional, desarrollador, consultor TI',
      requisitos: 'Secundario completo',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 6, 1),
    ),
    OfertaModel(
      ofertaId: 'oferta_isft234_1',
      institucionUid: 'isft234',
      nombre: 'Tecnicatura Superior en ConstrucciÃ³n Sustentable',
      descripcion:
          'FormaciÃ³n en construcciÃ³n con enfoque sustentable, eficiencia energÃ©tica y materiales ecolÃ³gicos.',
      area: 'IngenierÃ­a',
      nivel: 'Terciario',
      duracionAnios: 3,
      modalidad: 'Bimodal',
      salidaLaboral: 'TÃ©cnico en construcciÃ³n, proyectista, supervisor de obras',
      requisitos: 'Secundario completo',
      tag: 'NUEVO',
      aprobada: true,
      createdAt: DateTime(2026, 6, 1),
    ),
    OfertaModel(
      ofertaId: 'oferta_unpaz_1',
      institucionUid: 'unpaz',
      nombre: 'Licenciatura en EnfermerÃ­a',
      descripcion:
          'FormaciÃ³n mÃ©dica con Ã©nfasis en salud pÃºblica y atenciÃ³n primaria. PrÃ¡cticas en hospitales de la zona.',
      area: 'Salud',
      nivel: 'Universitario',
      duracionAnios: 5,
      modalidad: 'Presencial',
      salidaLaboral: 'Enfermero/a universitario/a, investigador/a, gestor/a de salud',
      requisitos: 'Secundario completo. Ingreso irrestricto.',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 6, 1),
    ),
  ]);

  for (final oferta in ofertas) {
    batch.set(
      firestore.collection('ofertas').doc(oferta.ofertaId),
      oferta.toMap(),
      SetOptions(merge: false),
    );
  }

  batch.set(
    firestore.collection('ofertas').doc('oferta_seed_v6_zona_norte'),
    {'trigger': true, 'createdAt': DateTime.now()},
    SetOptions(merge: false),
  );

  await batch.commit();
}

Future<void> seedCarrerasCompletas() async {
  final firestore = FirebaseFirestore.instance;
  final batch = firestore.batch();

  final carreras = [
    // --- UNPAZ (completa la lista) ---
    OfertaModel(
      ofertaId: 'oferta_unpaz_2',
      institucionUid: 'unpaz',
      nombre: 'AbogacÃ­a',
      descripcion:
          'FormaciÃ³n en derecho con Ã©nfasis en derechos humanos, procesos de integraciÃ³n regional y acceso a la justicia. ClÃ­nicas jurÃ­dicas gratuitas para la comunidad.',
      area: 'Derecho',
      nivel: 'Universitario',
      duracionAnios: 5,
      modalidad: 'Presencial',
      salidaLaboral: 'Abogado/a, defensor/a pÃºblico/a, asesor/a legal, mediador/a',
      requisitos: 'Secundario completo. Ingreso irrestricto.',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 6, 5),
    ),
    OfertaModel(
      ofertaId: 'oferta_unpaz_3',
      institucionUid: 'unpaz',
      nombre: 'Licenciatura en Trabajo Social',
      descripcion:
          'FormaciÃ³n en intervenciÃ³n social, polÃ­ticas pÃºblicas y trabajo territorial. PrÃ¡cticas en organizaciones sociales del distrito.',
      area: 'Ciencias Sociales',
      nivel: 'Universitario',
      duracionAnios: 4,
      modalidad: 'Presencial',
      salidaLaboral:
          'Trabajador/a social, gestor/a de polÃ­ticas, referente territorial',
      requisitos: 'Secundario completo. Ingreso irrestricto.',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 6, 5),
    ),
    OfertaModel(
      ofertaId: 'oferta_unpaz_4',
      institucionUid: 'unpaz',
      nombre: 'Licenciatura en AdministraciÃ³n',
      descripcion:
          'GestiÃ³n de organizaciones pÃºblicas y privadas, economÃ­a social y desarrollo local. Proyectos con PyMEs de la regiÃ³n.',
      area: 'AdministraciÃ³n',
      nivel: 'Universitario',
      duracionAnios: 4,
      modalidad: 'Presencial',
      salidaLaboral:
          'Administrador/a, gestor/a empresarial, analista financiero, consultor/a',
      requisitos: 'Secundario completo. Ingreso irrestricto.',
      tag: 'FECHAS IMPORTANTES',
      aprobada: true,
      createdAt: DateTime(2026, 6, 5),
    ),
    OfertaModel(
      ofertaId: 'oferta_unpaz_5',
      institucionUid: 'unpaz',
      nombre: 'Licenciatura en EducaciÃ³n',
      descripcion:
          'FormaciÃ³n de profesionales de la educaciÃ³n con enfoque en inclusiÃ³n, tecnologÃ­a educativa y polÃ­ticas de niÃ±ez y juventud.',
      area: 'EducaciÃ³n',
      nivel: 'Universitario',
      duracionAnios: 4,
      modalidad: 'Presencial',
      salidaLaboral:
          'Docente, pedagogo/a, diseÃ±ador/a curricular, gestor/a educativo/a',
      requisitos: 'Secundario completo. Ingreso irrestricto.',
      tag: 'BECAS',
      aprobada: true,
      createdAt: DateTime(2026, 6, 5),
    ),
    OfertaModel(
      ofertaId: 'oferta_unpaz_6',
      institucionUid: 'unpaz',
      nombre: 'Contador PÃºblico',
      descripcion:
          'FormaciÃ³n en contabilidad, auditorÃ­a, impuestos y finanzas con perspectiva de desarrollo regional. PrÃ¡cticas en estudios contables.',
      area: 'EconomÃ­a',
      nivel: 'Universitario',
      duracionAnios: 5,
      modalidad: 'Presencial',
      salidaLaboral:
          'Contador/a pÃºblico/a, auditor/a, asesor/a impositivo/a',
      requisitos: 'Secundario completo. Ingreso irrestricto.',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 6, 5),
    ),
    // --- ISFT 182 (San Miguel) ---
    OfertaModel(
      ofertaId: 'oferta_isft182_2',
      institucionUid: 'isft182',
      nombre: 'Tecnicatura Superior en EnfermerÃ­a',
      descripcion:
          'FormaciÃ³n en cuidados enfermeros con rotaciones hospitalarias y atenciÃ³n primaria de la salud. Enfoque comunitario.',
      area: 'Salud',
      nivel: 'Terciario',
      duracionAnios: 3,
      modalidad: 'Presencial',
      salidaLaboral:
          'Enfermero/a, enfermero/a jefe, gestor/a de salud',
      requisitos: 'Secundario completo. Examen de ingreso.',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 6, 5),
    ),
    OfertaModel(
      ofertaId: 'oferta_isft182_3',
      institucionUid: 'isft182',
      nombre: 'Tecnicatura Superior en Recursos Humanos',
      descripcion:
          'GestiÃ³n del capital humano: selecciÃ³n, capacitaciÃ³n, liquidaciÃ³n de sueldos y administraciÃ³n de personal.',
      area: 'AdministraciÃ³n',
      nivel: 'Terciario',
      duracionAnios: 2,
      modalidad: 'Presencial',
      salidaLaboral:
          'TÃ©cnico/a en RRHH, selector/a de personal, capacitador/a, liquidador/a',
      requisitos: 'Secundario completo',
      tag: 'NUEVO',
      aprobada: true,
      createdAt: DateTime(2026, 6, 5),
    ),
    OfertaModel(
      ofertaId: 'oferta_isft182_4',
      institucionUid: 'isft182',
      nombre: 'Tecnicatura Superior en BibliotecologÃ­a',
      descripcion:
          'OrganizaciÃ³n, gestiÃ³n y difusiÃ³n de colecciones bibliogrÃ¡ficas y recursos de informaciÃ³n en bibliotecas, archivos y centros de documentaciÃ³n.',
      area: 'Humanidades',
      nivel: 'Terciario',
      duracionAnios: 2,
      modalidad: 'Presencial',
      salidaLaboral:
          'Bibliotecario/a, gestor/a documental, auxiliar de bibliotecas',
      requisitos: 'Secundario completo',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 6, 5),
    ),
    OfertaModel(
      ofertaId: 'oferta_isft182_5',
      institucionUid: 'isft182',
      nombre: 'Tecnicatura Superior en Higiene y Seguridad en el Trabajo',
      descripcion:
          'PrevenciÃ³n de riesgos laborales, control de condiciones ambientales y confecciÃ³n de planes de evacuaciÃ³n.',
      area: 'IngenierÃ­a',
      nivel: 'Terciario',
      duracionAnios: 2,
      modalidad: 'Presencial',
      salidaLaboral:
          'TÃ©cnico/a en higiene y seguridad, asesor/a de prevenciÃ³n, auditor/a',
      requisitos: 'Secundario completo',
      tag: 'FECHAS IMPORTANTES',
      aprobada: true,
      createdAt: DateTime(2026, 6, 5),
    ),
    // --- ISFT 184 (Pilar) ---
    OfertaModel(
      ofertaId: 'oferta_isft184_2',
      institucionUid: 'isft184',
      nombre: 'Tecnicatura Superior en Coaching Educativo',
      descripcion:
          'FormaciÃ³n para acompaÃ±ar procesos de aprendizaje y desarrollo personal en Ã¡mbitos educativos y organizacionales.',
      area: 'EducaciÃ³n',
      nivel: 'Terciario',
      duracionAnios: 2,
      modalidad: 'Presencial',
      salidaLaboral:
          'Coach educativo/a, orientador/a vocacional, formador/a',
      requisitos: 'Secundario completo',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 6, 5),
    ),
    OfertaModel(
      ofertaId: 'oferta_isft184_3',
      institucionUid: 'isft184',
      nombre: 'Tecnicatura Superior en Contabilidad',
      descripcion:
          'RegistraciÃ³n contable, liquidaciÃ³n de impuestos y cierres de ejercicio. PrÃ¡cticas en estudios contables de la zona.',
      area: 'EconomÃ­a',
      nivel: 'Terciario',
      duracionAnios: 2,
      modalidad: 'Presencial',
      salidaLaboral:
          'TÃ©cnico/a contable, auxiliar impositivo/a, liquidador/a',
      requisitos: 'Secundario completo',
      tag: 'BECAS',
      aprobada: true,
      createdAt: DateTime(2026, 6, 5),
    ),
    OfertaModel(
      ofertaId: 'oferta_isft184_4',
      institucionUid: 'isft184',
      nombre: 'Tecnicatura Superior en Comercio Internacional',
      descripcion:
          'Negocios internacionales, logÃ­stica, aduana y operaciones de exportaciÃ³n e importaciÃ³n. Simulaciones de comercio exterior.',
      area: 'AdministraciÃ³n',
      nivel: 'Terciario',
      duracionAnios: 3,
      modalidad: 'Presencial',
      salidaLaboral:
          'Despachante de aduana, operador/a de comercio exterior, logÃ­stico/a',
      requisitos: 'Secundario completo',
      tag: 'NUEVO',
      aprobada: true,
      createdAt: DateTime(2026, 6, 5),
    ),
    OfertaModel(
      ofertaId: 'oferta_isft184_5',
      institucionUid: 'isft184',
      nombre: 'Tecnicatura Superior en GestiÃ³n Ambiental',
      descripcion:
          'GestiÃ³n de residuos, auditorÃ­a ambiental y sustentabilidad en organizaciones. Trabajo de campo en el corredor del RÃ­o LujÃ¡n.',
      area: 'Ciencias Ambientales',
      nivel: 'Terciario',
      duracionAnios: 2,
      modalidad: 'Presencial',
      salidaLaboral:
          'TÃ©cnico/a ambiental, auditor/a, gestor/a de residuos',
      requisitos: 'Secundario completo',
      tag: 'FECHAS IMPORTANTES',
      aprobada: true,
      createdAt: DateTime(2026, 6, 5),
    ),
    OfertaModel(
      ofertaId: 'oferta_isft184_6',
      institucionUid: 'isft184',
      nombre: 'Tecnicatura Superior en Seguridad e Higiene',
      descripcion:
          'PrevenciÃ³n de accidentes laborales y enfermedades profesionales en plantas industriales y obras.',
      area: 'IngenierÃ­a',
      nivel: 'Terciario',
      duracionAnios: 2,
      modalidad: 'Presencial',
      salidaLaboral:
          'TÃ©cnico/a en higiene y seguridad, supervisor/a de obra',
      requisitos: 'Secundario completo',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 6, 5),
    ),
    // --- ISFT 234 (Los Polvorines) ---
    OfertaModel(
      ofertaId: 'oferta_isft234_2',
      institucionUid: 'isft234',
      nombre: 'Tecnicatura Superior en EnfermerÃ­a',
      descripcion:
          'Cuidados enfermeros con rotaciones en el Hospital Mercante y en la red de salud del distrito. Modalidad bimodal.',
      area: 'Salud',
      nivel: 'Terciario',
      duracionAnios: 3,
      modalidad: 'Bimodal',
      salidaLaboral:
          'Enfermero/a, enfermero/a jefe, gestor/a de salud',
      requisitos: 'Secundario completo. Examen de ingreso.',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 6, 5),
    ),
    OfertaModel(
      ofertaId: 'oferta_isft234_3',
      institucionUid: 'isft234',
      nombre: 'Tecnicatura Superior en AnÃ¡lisis de Sistemas',
      descripcion:
          'AnÃ¡lisis, diseÃ±o e implementaciÃ³n de sistemas informÃ¡ticos. PrÃ¡cticas profesionalizantes en el polo tecnolÃ³gico de la zona.',
      area: 'TecnologÃ­a',
      nivel: 'Terciario',
      duracionAnios: 3,
      modalidad: 'Bimodal',
      salidaLaboral:
          'Analista funcional, desarrollador/a, consultor/a TI',
      requisitos: 'Secundario completo',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 6, 5),
    ),
    OfertaModel(
      ofertaId: 'oferta_isft234_4',
      institucionUid: 'isft234',
      nombre: 'Tecnicatura Superior en Periodismo Deportivo',
      descripcion:
          'Periodismo deportivo en radio, televisiÃ³n y medios digitales. Relatos, crÃ³nicas y coberturas en vivo.',
      area: 'Creativa',
      nivel: 'Terciario',
      duracionAnios: 2,
      modalidad: 'Presencial',
      salidaLaboral:
          'Periodista deportivo/a, relator/a, cronista, productor/a',
      requisitos: 'Secundario completo',
      tag: 'NUEVO',
      aprobada: true,
      createdAt: DateTime(2026, 6, 5),
    ),
    OfertaModel(
      ofertaId: 'oferta_isft234_5',
      institucionUid: 'isft234',
      nombre: 'Tecnicatura Superior en AcompaÃ±amiento TerapÃ©utico',
      descripcion:
          'AcompaÃ±amiento de personas con padecimientos subjetivos en el marco de equipos interdisciplinarios de salud.',
      area: 'Salud',
      nivel: 'Terciario',
      duracionAnios: 3,
      modalidad: 'Bimodal',
      salidaLaboral:
          'AcompaÃ±ante terapÃ©utico/a, integrante de equipos de salud',
      requisitos: 'Secundario completo',
      tag: 'BECAS',
      aprobada: true,
      createdAt: DateTime(2026, 6, 5),
    ),
    OfertaModel(
      ofertaId: 'oferta_isft234_6',
      institucionUid: 'isft234',
      nombre: 'Tecnicatura Superior en Recursos Humanos',
      descripcion:
          'SelecciÃ³n, capacitaciÃ³n y administraciÃ³n de personal. PrÃ¡cticas en empresas del Parque Industrial de Malvinas Argentinas.',
      area: 'AdministraciÃ³n',
      nivel: 'Terciario',
      duracionAnios: 2,
      modalidad: 'Bimodal',
      salidaLaboral:
          'TÃ©cnico/a en RRHH, selector/a de personal, capacitador/a',
      requisitos: 'Secundario completo',
      tag: 'FECHAS IMPORTANTES',
      aprobada: true,
      createdAt: DateTime(2026, 6, 5),
    ),
  ];

  for (final oferta in carreras) {
    batch.set(
      firestore.collection('ofertas').doc(oferta.ofertaId),
      oferta.toMap(),
      SetOptions(merge: false),
    );
  }

  batch.delete(
    firestore.collection('ofertas').doc('oferta_isft182_6'),
  );

  batch.set(
    firestore.collection('ofertas').doc('oferta_seed_v8_carreras_completas'),
    {'trigger': true, 'createdAt': DateTime.now()},
    SetOptions(merge: false),
  );

  await batch.commit();
  debugPrint('seedCarrerasCompletas: ${carreras.length} carreras agregadas');
}

Future<void> eliminarIsft180() async {
  final firestore = FirebaseFirestore.instance;
  final batch = firestore.batch();

  batch.delete(firestore.collection('instituciones').doc('isft180'));

  final ofertasSnap = await firestore
      .collection('ofertas')
      .where('institucionUid', isEqualTo: 'isft180')
      .get();
  for (final doc in ofertasSnap.docs) {
    batch.delete(doc.reference);
  }

  batch.set(
    firestore.collection('instituciones').doc('eliminar_isft180_v1'),
    {'trigger': true, 'createdAt': DateTime.now()},
    SetOptions(merge: false),
  );

  await batch.commit();
  debugPrint(
      'eliminarIsft180: ${ofertasSnap.docs.length} ofertas y la instituciÃ³n eliminadas');
}

Future<void> seedLogosStorage() async {
  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  final snap = await firestore.collection('instituciones').get();
  final batch = firestore.batch();
  var migrados = 0;

  for (final doc in snap.docs) {
    final data = doc.data();
    final urls = data['logoURL'] as String? ?? '';
    if (urls.trim().isEmpty) continue;
    if (urls.contains('firebasestorage.app')) continue;

    try {
      final response = await http.get(Uri.parse(urls));
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) continue;

      final ext = _extensionDesdeUrl(urls);
      final ref = storage.ref('instituciones_logos/${doc.id}$ext');
      await ref.putData(
        response.bodyBytes,
        SettableMetadata(contentType: response.headers['content-type']),
      );
      final downloadUrl = await ref.getDownloadURL();
      batch.update(doc.reference, {'logoURL': downloadUrl});
      migrados++;
    } catch (_) {
      continue;
    }
  }

  batch.set(
    firestore.collection('instituciones').doc('logos_storage_v1'),
    {'trigger': true, 'createdAt': DateTime.now()},
    SetOptions(merge: false),
  );

  await batch.commit();
  debugPrint(
      'seedLogosStorage: $migrados logos migrados a Firebase Storage');
}

String _extensionDesdeUrl(String url) {
  try {
    var path = Uri.parse(url).path;
    final dot = path.lastIndexOf('.');
    if (dot == -1) return '.png';
    final ext = path.substring(dot).toLowerCase();
    if (RegExp(r'^\.[a-z]{2,4}$').hasMatch(ext)) return ext;
  } catch (_) {}
  return '.png';
}

const Map<String, String> _logosPorNombre = {
  'austral': 'https://www.austral.edu.ar/wp-content/uploads/2022/09/logo-md-austral-1.png',
  'universidad austral':
      'https://www.austral.edu.ar/wp-content/uploads/2022/09/logo-md-austral-1.png',
  'uai zona norte': 'https://uai.edu.ar/media/137710/uainuevo.png',
  'uai': 'https://uai.edu.ar/media/137710/uainuevo.png',
  'belgrano': 'https://ub.edu.ar/sites/default/files/iso-web-2025_0.png',
  'universidad de belgrano':
      'https://ub.edu.ar/sites/default/files/iso-web-2025_0.png',
  'uba cbc tigre': 'https://www.uba.ar/imgs/logofooter.png',
  'cbc': 'https://www.uba.ar/imgs/logofooter.png',
  'cbc tigre': 'https://www.uba.ar/imgs/logofooter.png',
  'uces': 'https://upload.wikimedia.org/wikipedia/commons/0/07/Uces_logo_simple.png',
  'san andres': 'https://upload.wikimedia.org/wikipedia/commons/3/3f/UdeSA.png',
  'universidad de san andres':
      'https://upload.wikimedia.org/wikipedia/commons/3/3f/UdeSA.png',
  'udesa': 'https://upload.wikimedia.org/wikipedia/commons/3/3f/UdeSA.png',
  'unlu': 'https://www.unlu.edu.ar/imagenes/logo-transparente-escudo-titulo-bl-pant2021b.png',
  'universidad nacional de lujan':
      'https://www.unlu.edu.ar/imagenes/logo-transparente-escudo-titulo-bl-pant2021b.png',
  'san miguel': 'https://isft182-bue.infd.edu.ar/sitio/wp-content/uploads/2018/09/isft182_logo.png',
  'unt regional': 'https://upload.wikimedia.org/wikipedia/commons/7/75/Untref_logo.png',
  'untref': 'https://upload.wikimedia.org/wikipedia/commons/7/75/Untref_logo.png',
  'tres de febrero': 'https://upload.wikimedia.org/wikipedia/commons/7/75/Untref_logo.png',
  'del salvador': 'https://www.usal.edu.ar/images/logo.png',
  'universidad del salvador': 'https://www.usal.edu.ar/images/logo.png',
};

String _normalizarNombre(String nombre) {
  const conAcentos = 'Ã¡Ã©Ã­Ã³ÃºÃ¼Ã±';
  const sinAcentos = 'aeioun';
  final lower = nombre.toLowerCase().trim();
  final buffer = StringBuffer();
  for (final char in lower.split('')) {
    final index = conAcentos.indexOf(char);
    buffer.write(index >= 0 ? sinAcentos[index] : char);
  }
  return buffer.toString().replaceAll(RegExp(r'\s+'), ' ');
}

Future<void> patchInstitucionesSinLogo() async {
  final firestore = FirebaseFirestore.instance;
  final snapshot = await firestore.collection('instituciones').get();
  final batch = firestore.batch();
  var actualizadas = 0;
  for (final doc in snapshot.docs) {
    final data = doc.data();
    final logoActual = (data['logoURL'] as String? ?? '').trim();
    if (logoActual.isNotEmpty) continue;
    final nombre = data['nombre'] as String? ?? '';
    final logo = _logosPorNombre[_normalizarNombre(nombre)];
    if (logo == null) continue;
    batch.update(doc.reference, {'logoURL': logo});
    actualizadas++;
  }
  if (actualizadas > 0) {
    await batch.commit();
  }
  await firestore.collection('ofertas').doc('patch_logos_v1').set(
        {'trigger': true, 'createdAt': DateTime.now()},
        SetOptions(merge: false),
      );
  debugPrint('patchInstitucionesSinLogo: $actualizadas instituciones actualizadas');
}

/// Instituciones agregadas despues del seed original. Se definen aparte para que
/// el parche pueda crearlas en bases ya sembradas, donde seedData() ya corrio.
/// Instituciones que alguna vez se sembraron aparte. Hoy la app usa el
/// catalogo externo, asi que ya no se crean desde aca: si se volvieran a
/// sembrar, resucitarian instituciones que se borraron (USAL, ISFDyT N°35).
List<InstitucionModel> institucionesNuevas() => [];

/// Logo de la Facultad de Ciencias Juridicas de la USAL. Es vertical, asi que
/// va con logoContained para que no se recorte en los avatares circulares.
const String _logoUsalRemoto =
    'https://i0.wp.com/cedaeonline.com.ar/wp-content/uploads/2018/10/logo-USAL-ciencias-jurÃ­dicas.jpg?ssl=1';

const Map<String, String> _logosAssetPorUid = {
  'utn': 'assets/imagenes/instituciones/utn.jpg',
  'unlp': 'assets/imagenes/instituciones/unlp.png',
  'unsam': 'assets/imagenes/instituciones/unsam.png',
  'unq': 'assets/imagenes/instituciones/unq.png',
  'unicen': 'assets/imagenes/instituciones/unicen.jpg',
  'unmdp': 'assets/imagenes/instituciones/unmdp.png',
  'ungs': 'assets/imagenes/instituciones/ungs.png',
  'unlz': 'assets/imagenes/instituciones/unlz.png',
  'unpaz': 'assets/imagenes/instituciones/unpaz.png',
  'isft184': 'assets/imagenes/instituciones/isft184.jpg',
  'isft182': 'assets/imagenes/instituciones/isft182.jpg',
  'isft234': 'assets/imagenes/instituciones/isft234.png',
  'isfdyt35': 'assets/imagenes/instituciones/isfdyt35.jpg',
  // Instituciones que viven solo en Firestore, sembradas por otras vias.
  // Los nombres de doc no coinciden con el nombre de la institucion.
  'austral_pilar': 'assets/imagenes/instituciones/austral.png',
  'ub_tigre': 'assets/imagenes/instituciones/belgrano.jpg',
  'uai_tigre': 'assets/imagenes/instituciones/uai.jpg',
  'uba_cbc_tigre': 'assets/imagenes/instituciones/uba.png',
  'uces_tigre': 'assets/imagenes/instituciones/uces.png',
  'udesa': 'assets/imagenes/instituciones/udesa.png',
  'unlu_sanmiguel': 'assets/imagenes/instituciones/unlu.png',
};

/// Instituciones cuyo logo es vertical o apaisado y por lo tanto se muestra
/// completo con BoxFit.contain sobre fondo, en vez de recortarse con cover.
const Set<String> _uidsLogoContained = {
  'usal',
  'utn',
  'unlz',
  'unq',
  'unicen',
  'isfdyt35',
  'unsam',
  'unpaz',
  'isft182',
  'isft234',
  'austral_pilar',
  'ub_tigre',
  'uai_tigre',
  'uba_cbc_tigre',
  'uces_tigre',
  'udesa',
  'unlu_sanmiguel',
};

const Map<String, String> _fotosCampusPorUid = {
  'unpaz': 'assets/imagenes/campus/unpaz.jpg',
  'ungs': 'assets/imagenes/campus/ungs.jpg',
  'usal': 'assets/imagenes/campus/usal.jpg',
  'isfdyt35': 'assets/imagenes/campus/isfdyt35.jpg',
};

/// Rellena logoAsset y fotoCampus en documentos ya sembrados antes de que
/// existieran estos campos, para no depender de re-sembrar todo el seed.
Future<void> patchInstitucionesAssetsLocales() async {
  final firestore = FirebaseFirestore.instance;

  // Instituciones agregadas despues del seed original: crearlas si faltan.
  var creadas = 0;
  for (final inst in institucionesNuevas()) {
    final ref = firestore.collection('instituciones').doc(inst.institucionUid);
    final doc = await ref.get();
    if (!doc.exists) {
      await ref.set(inst.toMap());
      creadas++;
    }
  }

  final snapshot = await firestore.collection('instituciones').get();
  final batch = firestore.batch();
  var actualizadas = 0;
  for (final doc in snapshot.docs) {
    final data = doc.data();
    final uid = doc.id;
    final cambios = <String, dynamic>{};
    // Comparar contra la ruta y no solo contra vacio: los archivos se renombran
    // (utn.png -> utn.jpg) y la ruta vieja en Firestore quedaria colgada.
    final logoAsset = _logosAssetPorUid[uid];
    if (logoAsset != null && (data['logoAsset'] as String? ?? '') != logoAsset) {
      cambios['logoAsset'] = logoAsset;
    }
    final foto = _fotosCampusPorUid[uid];
    if (foto != null && (data['fotoCampus'] as String? ?? '').trim().isEmpty) {
      cambios['fotoCampus'] = foto;
    }
    // Logos verticales o apaisados: mostrarlos completos, sin recorte.
    if (_uidsLogoContained.contains(uid) && data['logoContained'] != true) {
      cambios['logoContained'] = true;
    }
    // USAL paso a logo remoto de la facultad: hay que SACAR el asset local
    // aunque ya este puesto, y forzar la URL, no solo rellenar vacios.
    if (uid == 'usal') {
      if ((data['logoURL'] as String? ?? '') != _logoUsalRemoto) {
        cambios['logoURL'] = _logoUsalRemoto;
      }
      if ((data['logoAsset'] as String? ?? '').isNotEmpty) {
        cambios['logoAsset'] = '';
      }
    }
    if (cambios.isEmpty) continue;
    batch.update(doc.reference, cambios);
    actualizadas++;
  }
  if (actualizadas > 0) {
    await batch.commit();
  }
  debugPrint(
      'patchInstitucionesAssetsLocales: $creadas creadas, $actualizadas con asset local');
}

Future<void> seedAvisos() async {
  final firestore = FirebaseFirestore.instance;
  final batch = firestore.batch();

  final avisos = [
    {
      'titulo': 'Inscripciones abiertas 2027',
      'mensaje':
          'Se encuentran abiertas las inscripciones para el ciclo lectivo 2027 en las universidades de la regiÃ³n. ConsultÃ¡ las fechas de cada instituciÃ³n.',
      'tipo': 'inscripcion',
      'link': '/map',
      'publicado': DateTime(2026, 9, 12),
    },
    {
      'titulo': 'Nuevas fechas de ingreso en zona norte',
      'mensaje':
          'Las universidades de la zona norte confirmaron nuevas fechas de ingreso e inscripciÃ³n. IngresÃ¡ y revisÃ¡ los requisitos por carrera.',
      'tipo': 'noticia',
      'link': '/map',
      'publicado': DateTime(2026, 9, 5),
    },
    {
      'titulo': 'Â¿TodavÃ­a no hacÃ©s tu test vocacional?',
      'mensaje':
          'DescubrÃ­ quÃ© carrera se ajusta a tus intereses con nuestro test vocacional gratuito. Te lleva menos de 5 minutos.',
      'tipo': 'consejo',
      'link': '/test',
      'publicado': DateTime(2026, 8, 28),
    },
  ];

  for (final aviso in avisos) {
    final id = 'aviso_${(aviso['titulo'] as String).toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_')}';
    batch.set(firestore.collection('avisos').doc(id), aviso);
  }

  batch.set(
    firestore.collection('avisos').doc('avisos_seed_v1'),
    {'trigger': true, 'createdAt': DateTime.now()},
    SetOptions(merge: false),
  );

  await batch.commit();
}

Future<void> seedFavoritosDemo(String uid) async {
  final firestore = FirebaseFirestore.instance;

  const favoritos = [
    (ofertaId: 'oferta_utn_3', institucionUid: 'utn'),
    (ofertaId: 'oferta_unpaz_1', institucionUid: 'unpaz'),
    (ofertaId: 'oferta_ungs_3', institucionUid: 'ungs'),
    (ofertaId: 'oferta_isft182_1', institucionUid: 'isft182'),
  ];

  final batch = firestore.batch();
  for (final fav in favoritos) {
    final ref =
        firestore.collection('usuarios').doc(uid).collection('favoritos').doc();
    batch.set(ref, {
      'ofertaId': fav.ofertaId,
      'institucionUid': fav.institucionUid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  batch.set(
    firestore.collection('ofertas').doc('favoritos_seed_v1'),
    {'trigger': true, 'createdAt': DateTime.now()},
    SetOptions(merge: false),
  );

  await batch.commit();
  debugPrint('seedFavoritosDemo: ${favoritos.length} favoritos guardados');
}
