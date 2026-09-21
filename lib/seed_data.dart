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
          'La Universidad Tecnológica Nacional es una institución pública de educación superior dedicada a la formación de profesionales en ingeniería y afines.',
      direccion: 'Av. Madero 399',
      ciudad: 'Ciudad Autónoma de Buenos Aires',
      provincia: 'CABA',
      telefono: '(011) 4867-7500',
      email: 'info@frba.utn.edu.ar',
      sitioWeb: 'https://frba.utn.edu.ar',
      logoURL: 'https://utn.edu.ar/images/logo-utn.png',
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
          'Formación integral en análisis, diseño e implementación de sistemas informáticos. Incluye prácticas profesionalizantes en empresas del sector.',
      area: 'Tecnología',
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
      nombre: 'Ingeniería en Sistemas',
      descripcion:
          'Carrera de grado con enfoque en desarrollo de software, gestión de proyectos tecnológicos y arquitectura de sistemas.',
      area: 'Tecnología',
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
      nombre: 'Tecnicatura en Programación',
      descripcion:
          'Carrera de formación rápida en desarrollo de software, bases de datos y aplicaciones web. 100% orientada a la inserción laboral.',
      area: 'Tecnología',
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
      nombre: 'Ingeniería Civil',
      descripcion:
          'Formación en diseño, cálculo y construcción de obras civiles. Laboratorios equipados y convenios con empresas constructoras.',
      area: 'Ingeniería',
      nivel: 'Universitario',
      duracionAnios: 5,
      modalidad: 'Presencial',
      salidaLaboral: 'Ingeniero civil, proyectista, gerente de obra',
      requisitos: 'Secundario completo con orientación en exactas',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 5, 12),
    ),
    OfertaModel(
      ofertaId: 'oferta_utn_5',
      institucionUid: 'utn',
      nombre: 'Ingeniería Electrónica',
      descripcion:
          'Carrera orientada a sistemas embebidos, automatización industrial y telecomunicaciones. Laboratorio de microcontroladores incluido.',
      area: 'Ingeniería',
      nivel: 'Universitario',
      duracionAnios: 5,
      modalidad: 'Presencial',
      salidaLaboral:
          'Ingeniero electrónico, automatizador, diseñador de hardware',
      requisitos: 'Secundario completo',
      tag: 'BECAS',
      aprobada: true,
      createdAt: DateTime(2026, 5, 6),
    ),
    OfertaModel(
      ofertaId: 'oferta_utn_6',
      institucionUid: 'utn',
      nombre: 'Licenciatura en Administración',
      descripcion:
          'Formación en gestión empresarial, recursos humanos y finanzas. Modalidad cursada flexible con horarios rotativos.',
      area: 'Administración',
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
          'La Universidad Nacional de La Plata es una de las principales universidades públicas de Argentina, fundada en 1905.',
      direccion: 'Av. 7 N° 776',
      ciudad: 'La Plata',
      provincia: 'Buenos Aires',
      telefono: '(0221) 423-6800',
      email: 'info@unlp.edu.ar',
      sitioWeb: 'https://www.unlp.edu.ar',
      logoURL: 'https://unlp.edu.ar/wp-content/uploads/2022/07/UNLP.png',
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
      nombre: 'Licenciatura en Sistemas de Información',
      descripcion:
          'Formación en análisis, diseño y gestión de sistemas de información. Enfoque en ingeniería de software y tecnologías emergentes.',
      area: 'Tecnología',
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
      nombre: 'Abogacía',
      descripcion:
          'Carrera clásica de la UNLP con orientación en derecho público y privado. Clínicas jurídicas para práctica profesional.',
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
          'Formación médica con énfasis en salud pública y atención primaria. Hospital escuela con residencias propias.',
      area: 'Salud',
      nivel: 'Universitario',
      duracionAnios: 6,
      modalidad: 'Presencial',
      salidaLaboral: 'Médico general, especialista, investigador',
      requisitos: 'Secundario completo. Examen de admisión.',
      tag: 'FECHAS IMPORTANTES',
      aprobada: true,
      createdAt: DateTime(2026, 4, 15),
    ),
    OfertaModel(
      ofertaId: 'oferta_unlp_4',
      institucionUid: 'unlp',
      nombre: 'Licenciatura en Economía',
      descripcion:
          'Análisis económico con base matemática sólida. Perspectiva de economía política y desarrollo regional.',
      area: 'Economía',
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
          'Diseño arquitectónico con enfoque sustentable. Taller de diseño y госудancies con proyectos reales.',
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
          'Formación en periodismo escrito, audiovisual y digital. Taller de noticias y prácticas en medios.',
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
          'La Universidad Nacional de San Martín, fundada en 2009, se destaca por su enfoque interdisciplinario y producción de conocimiento.',
      direccion: '25 de Mayo y Francia',
      ciudad: 'San Martín',
      provincia: 'Buenos Aires',
      telefono: '(011) 4006-1500',
      email: 'rrectorado@unsam.edu.ar',
      sitioWeb: 'https://www.unsam.edu.ar',
      logoURL: 'https://www.unsam.edu.ar/img/logo-UNSAM.png',
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
      nombre: 'Tecnicatura en Producción Audiovisual',
      descripcion:
          'Formación en cine, televisión y producción digital. Equipamiento profesional y profesores del sector.',
      area: 'Creativa',
      nivel: 'Terciario',
      duracionAnios: 3,
      modalidad: 'Presencial',
      salidaLaboral:
          'Director, productor, editor, camarógrafo, sonidista',
      requisitos: 'Secundario completo. Portafolio recomendado.',
      tag: 'NUEVO',
      aprobada: true,
      createdAt: DateTime(2026, 3, 25),
    ),
    OfertaModel(
      ofertaId: 'oferta_unsam_2',
      institucionUid: 'unsam',
      nombre: 'Licenciatura en Biotecnología',
      descripcion:
          'Carrera interdisciplinaria que combina biología molecular, química y bioinformática. Laboratorios de última generación.',
      area: 'Salud',
      nivel: 'Universitario',
      duracionAnios: 5,
      modalidad: 'Presencial',
      salidaLaboral:
          'Biotecnólogo, investigador, analista en laboratorio',
      requisitos: 'Secundario completo. Orientación en ciencias naturales.',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 3, 20),
    ),
    OfertaModel(
      ofertaId: 'oferta_unsam_3',
      institucionUid: 'unsam',
      nombre: 'Tecnicatura en Programación',
      descripcion:
          'Desarrollo de software con foco en buenas prácticas, testing y metodologías ágiles. Proyectos grupales reales.',
      area: 'Tecnología',
      nivel: 'Terciario',
      duracionAnios: 2,
      modalidad: 'Presencial',
      salidaLaboral: 'Programador, desarrollador web y móvil',
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
          'Análisis de la política internacional, diplomacia y comercio exterior. Simulaciones de negociación y Model ONU.',
      area: 'Ciencias Sociales',
      nivel: 'Universitario',
      duracionAnios: 4,
      modalidad: 'Presencial',
      salidaLaboral:
          'Relacionista internacional, diplomático, analista político',
      requisitos: 'Secundario completo',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 3, 15),
    ),
    OfertaModel(
      ofertaId: 'oferta_unsam_5',
      institucionUid: 'unsam',
      nombre: 'Licenciatura en Sociología',
      descripcion:
          'Estudio de la sociedad contemporánea, procesos sociales y metodología de investigación cualitativa y cuantitativa.',
      area: 'Ciencias Sociales',
      nivel: 'Universitario',
      duracionAnios: 4,
      modalidad: 'Presencial',
      salidaLaboral: 'Sociólogo, investigador, consultor social',
      requisitos: 'Secundario completo',
      tag: 'FECHAS IMPORTANTES',
      aprobada: true,
      createdAt: DateTime(2026, 3, 12),
    ),
    OfertaModel(
      ofertaId: 'oferta_unsam_6',
      institucionUid: 'unsam',
      nombre: 'Tecnicatura en Energías Renovables',
      descripcion:
          'Formación en instalación y mantenimiento de sistemas de energía solar, eólica y biomasa. Prácticas en plantas piloto.',
      area: 'Ingeniería',
      nivel: 'Terciario',
      duracionAnios: 2,
      modalidad: 'Presencial',
      salidaLaboral:
          'Técnico en energías renovables, instalador solar, consultor energético',
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
          'La Universidad Nacional de Quilmes es una universidad pública que se destaca por su compromiso con la inclusión social y la innovación pedagógica.',
      direccion: 'Roque Sáenz Peña 352',
      ciudad: 'Bernal',
      provincia: 'Buenos Aires',
      telefono: '(011) 4365-7100',
      email: 'info@unq.edu.ar',
      sitioWeb: 'https://www.unq.edu.ar',
      logoURL: 'https://www.unq.edu.ar/wp-content/uploads/2022/11/LOGO-UNQ.png',
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
      nombre: 'Licenciatura en Sociología',
      descripcion:
          'Carrera de referencia en sociología con énfasis en estudios urbanos y políticas públicas. Investigación aplicada.',
      area: 'Ciencias Sociales',
      nivel: 'Universitario',
      duracionAnios: 4,
      modalidad: 'Presencial',
      salidaLaboral: 'Sociólogo, analista de políticas públicas',
      requisitos: 'Secundario completo. Ingreso libre.',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 4, 5),
    ),
    OfertaModel(
      ofertaId: 'oferta_unq_2',
      institucionUid: 'unq',
      nombre: 'Tecnicatura en Regulación y Gestión de Servicios Públicos',
      descripcion:
          'Formación única en regulación de servicios públicos: agua, energía, transporte y telecomunicaciones.',
      area: 'Administración',
      nivel: 'Terciario',
      duracionAnios: 3,
      modalidad: 'Presencial',
      salidaLaboral:
          'Técnico regulador, consultor en servicios públicos',
      requisitos: 'Secundario completo',
      tag: 'NUEVO',
      aprobada: true,
      createdAt: DateTime(2026, 4, 3),
    ),
    OfertaModel(
      ofertaId: 'oferta_unq_3',
      institucionUid: 'unq',
      nombre: 'Licenciatura en Economía',
      descripcion:
          'Economía con perspectiva crítica y enfoque en desarrollo productivo regional. Seminarios con especialistas.',
      area: 'Economía',
      nivel: 'Universitario',
      duracionAnios: 4,
      modalidad: 'Presencial',
      salidaLaboral: 'Economista, analista de riesgo, funcionario público',
      requisitos: 'Secundario completo',
      tag: 'BECAS',
      aprobada: true,
      createdAt: DateTime(2026, 4, 1),
    ),
    OfertaModel(
      ofertaId: 'oferta_unq_4',
      institucionUid: 'unq',
      nombre: 'Licenciatura en Diseño',
      descripcion:
          'Diseño gráfico, industrial y de interacción. Taller con proyectos reales para empresas y organismos públicos.',
      area: 'Creativa',
      nivel: 'Universitario',
      duracionAnios: 4,
      modalidad: 'Presencial',
      salidaLaboral: 'Diseñador gráfico, UX designer, director de arte',
      requisitos: 'Secundario completo. Muestra de trabajos.',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 3, 28),
    ),
    OfertaModel(
      ofertaId: 'oferta_unq_5',
      institucionUid: 'unq',
      nombre: 'Tecnicatura en Producción Musical y Sonido',
      descripcion:
          'Formación en grabación, mezcla y producción musical. Estudio de grabación con equipamiento profesional.',
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
      nombre: 'Licenciatura en Política y Gestión Deportiva',
      descripcion:
          'Gestión de organizaciones deportivas, marketing deportivo y políticas públicas del deporte. Prácticas en clubes y federaciones.',
      area: 'Administración',
      nivel: 'Universitario',
      duracionAnios: 4,
      modalidad: 'Presencial',
      salidaLaboral:
          'Gestor deportivo, director de.entidades, asesor de políticas deportivas',
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
          'La Universidad Nacional del Centro de la Provincia de Buenos Aires, con sedes en Tandil, Azul y Olavarría, ofrece formación de calidad.',
      direccion: 'Gral. Pinto 399',
      ciudad: 'Tandil',
      provincia: 'Buenos Aires',
      telefono: '(0249) 438-5600',
      email: 'info@unicen.edu.ar',
      sitioWeb: 'https://www.unicen.edu.ar',
      logoURL: 'https://www.unicen.edu.ar/sites/all/themes/unicen/images/logo-50.png',
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
      nombre: 'Licenciatura en Ciencias de la Computación',
      descripcion:
          'Formación teórica y práctica en computación. Algoritmos, inteligencia artificial y ciencia de datos.',
      area: 'Tecnología',
      nivel: 'Universitario',
      duracionAnios: 5,
      modalidad: 'Presencial',
      salidaLaboral: 'Científico de datos, desarrollador, investigador',
      requisitos: 'Secundario completo. Examen de ingreso en exactas.',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 3, 30),
    ),
    OfertaModel(
      ofertaId: 'oferta_unicen_2',
      institucionUid: 'unicen',
      nombre: 'Tecnicatura en Instrumentación y Control',
      descripcion:
          'Medición, instrumentación y control de procesos industriales. Laboratorios con equipamiento industrial real.',
      area: 'Ingeniería',
      nivel: 'Terciario',
      duracionAnios: 3,
      modalidad: 'Presencial',
      salidaLaboral:
          'Técnico en instrumentación, control de procesos, automatización',
      requisitos: 'Secundario completo. Orientación técnica.',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 3, 28),
    ),
    OfertaModel(
      ofertaId: 'oferta_unicen_3',
      institucionUid: 'unicen',
      nombre: 'Licenciatura en Historia',
      descripcion:
          'Estudio de procesos históricos argentinos, latinoamericanos y mundiales. Archivos y fuentes primarias.',
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
      nombre: 'Tecnicatura en Gestión Ambiental',
      descripcion:
          'Gestión de residuos, auditoría ambiental y desarrollo sustentable. Trabajo de campo en parques naturales.',
      area: 'Ciencias Ambientales',
      nivel: 'Terciario',
      duracionAnios: 2,
      modalidad: 'Presencial',
      salidaLaboral:
          'Técnico ambiental, auditor, gestor de residuos',
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
          'Gestión turística, hotelería y desarrollo de destinos. Prácticas en hoteles y agencias de viajes de Tandil.',
      area: 'Administración',
      nivel: 'Universitario',
      duracionAnios: 4,
      modalidad: 'Presencial',
      salidaLaboral:
          'Gestor turístico, recepcionista, guía, emprendedor turístico',
      requisitos: 'Secundario completo',
      tag: 'FECHAS IMPORTANTES',
      aprobada: true,
      createdAt: DateTime(2026, 3, 20),
    ),
    OfertaModel(
      ofertaId: 'oferta_unicen_6',
      institucionUid: 'unicen',
      nombre: 'Ingeniería en Electrónica',
      descripcion:
          'Diseño de circuitos, sistemas embebidos y robótica. Electrónica aplicada a la industria y la salud.',
      area: 'Ingeniería',
      nivel: 'Universitario',
      duracionAnios: 5,
      modalidad: 'Presencial',
      salidaLaboral:
          'Ingeniero electrónico, diseñador de hardware, investigador',
      requisitos: 'Secundario completo con orientación en exactas',
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
          'Formación en biología marina, oceanografía y gestión de recursos acuáticos. Prácticas en el Instituto de Biología Marina.',
      area: 'Ciencias Ambientales',
      nivel: 'Universitario',
      duracionAnios: 5,
      modalidad: 'Presencial',
      salidaLaboral:
          'Científico marino, biólogo pesquero, gestor ambiental',
      requisitos: 'Secundario completo. Orientación en ciencias naturales.',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 4, 10),
    ),
    OfertaModel(
      ofertaId: 'oferta_unmdp_2',
      institucionUid: 'unmdp',
      nombre: 'Tecnicatura en Enfermería',
      descripcion:
          'Formación en cuidados enfermeros con rotaciones en hospitales públicos. Enfoque en salud comunitaria.',
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
      nombre: 'Licenciatura en Geografía',
      descripcion:
          'Estudio del territorio, SIG y cartografía. Trabajo de campo en la costa atlántica y regiones pampeanas.',
      area: 'Ciencias Sociales',
      nivel: 'Universitario',
      duracionAnios: 4,
      modalidad: 'Presencial',
      salidaLaboral:
          'Geógrafo, analista SIG, planificador territorial',
      requisitos: 'Secundario completo',
      tag: 'BECAS',
      aprobada: true,
      createdAt: DateTime(2026, 4, 5),
    ),
    OfertaModel(
      ofertaId: 'oferta_unmdp_4',
      institucionUid: 'unmdp',
      nombre: 'Tecnicatura en Gastronomía',
      descripcion:
          'Cocina argentina e internacional, pastelería y gestión de gastronomía. Prácticas en restaurantes de Mar del Plata.',
      area: 'Creativa',
      nivel: 'Terciario',
      duracionAnios: 2,
      modalidad: 'Presencial',
      salidaLaboral: 'Chef, pastelero, consultor gastronómico',
      requisitos: 'Secundario completo. Entrevista personal.',
      tag: 'NUEVO',
      aprobada: true,
      createdAt: DateTime(2026, 4, 3),
    ),
    OfertaModel(
      ofertaId: 'oferta_unmdp_5',
      institucionUid: 'unmdp',
      nombre: 'Licenciatura en Comunicación',
      descripcion:
          'Comunicación social, periodismo digital y producción de contenidos. Laboratorio de medios digitales.',
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
      nombre: 'Licenciatura en Economía',
      descripcion:
          'Economía con foco en recursos naturales y turismo. Análisis económico regional.',
      area: 'Economía',
      nivel: 'Universitario',
      duracionAnios: 4,
      modalidad: 'Presencial',
      salidaLaboral: 'Economista, analista, funcionario público',
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
          'La Universidad Nacional de General Sarmiento, en Los Polvorines, se especializa en ciencias sociales, tecnología y formación docente.',
      direccion: 'Juan María Gutiérrez 1150',
      ciudad: 'Los Polvorines',
      provincia: 'Buenos Aires',
      telefono: '(011) 4469-7500',
      email: 'info@campus.ungs.edu.ar',
      sitioWeb: 'https://www.ungs.edu.ar',
      logoURL: 'https://www.ungs.edu.ar/wp-content/uploads/2024/06/logo_ungs_512.png',
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
          'Planificación urbana, diseño de espacios públicos y gestión municipal. Taller con proyectos para el GCBA.',
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
      nombre: 'Tecnicatura en Mecatrónica',
      descripcion:
          'Automatización, robótica y sistemas mecatrónicos. Laboratorio con robots industriales y PLCs.',
      area: 'Ingeniería',
      nivel: 'Terciario',
      duracionAnios: 3,
      modalidad: 'Presencial',
      salidaLaboral:
          'Técnico mecatrónico, automatizador, programador de PLCs',
      requisitos: 'Secundario completo. Orientación técnica.',
      tag: 'NUEVO',
      aprobada: true,
      createdAt: DateTime(2026, 4, 10),
    ),
    OfertaModel(
      ofertaId: 'oferta_ungs_3',
      institucionUid: 'ungs',
      nombre: 'Licenciatura en Trabajo Social',
      descripcion:
          'Formación en intervención social, políticas públicas y trabajo comunitario. Prácticas en organizaciones sociales.',
      area: 'Ciencias Sociales',
      nivel: 'Universitario',
      duracionAnios: 4,
      modalidad: 'Presencial',
      salidaLaboral:
          'Trabajador social, asistente social, gestor de políticas',
      requisitos: 'Secundario completo',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 4, 8),
    ),
    OfertaModel(
      ofertaId: 'oferta_ungs_4',
      institucionUid: 'ungs',
      nombre: 'Licenciatura en Ciencias Políticas',
      descripcion:
          'Análisis político, gobierno y gestión pública. Simulaciones de debate y Model ONU.',
      area: 'Ciencias Sociales',
      nivel: 'Universitario',
      duracionAnios: 4,
      modalidad: 'Presencial',
      salidaLaboral:
          'Cientista político, funcionario, asesor legislativo',
      requisitos: 'Secundario completo',
      tag: 'FECHAS IMPORTANTES',
      aprobada: true,
      createdAt: DateTime(2026, 4, 5),
    ),
    OfertaModel(
      ofertaId: 'oferta_ungs_5',
      institucionUid: 'ungs',
      nombre: 'Tecnicatura en Programación',
      descripcion:
          'Desarrollo de software con metodologías ágiles. Frameworks modernos y buenas prácticas.',
      area: 'Tecnología',
      nivel: 'Terciario',
      duracionAnios: 2,
      modalidad: 'Presencial',
      salidaLaboral: 'Programador, desarrollador web y móvil',
      requisitos: 'Secundario completo',
      tag: 'BECAS',
      aprobada: true,
      createdAt: DateTime(2026, 4, 3),
    ),
    OfertaModel(
      ofertaId: 'oferta_ungs_6',
      institucionUid: 'ungs',
      nombre: 'Licenciatura en Diseño Industrial',
      descripcion:
          'Diseño de productos industriales con enfoque en sustentabilidad. Taller con prototipado digital.',
      area: 'Creativa',
      nivel: 'Universitario',
      duracionAnios: 5,
      modalidad: 'Presencial',
      salidaLaboral: 'Diseñador industrial, prototipador, consultor',
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
      nombre: 'Abogacía',
      descripcion:
          'Formación en derecho con énfasis en derechos humanos y justicia social. Clínicas jurídicas en zonas vulnerables.',
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
      nombre: 'Licenciatura en Ciencias Económicas',
      descripcion:
          'Economía, contabilidad y finanzas públicas. Enfoque en economía social y solidaria.',
      area: 'Economía',
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
      nombre: 'Licenciatura en Comunicación Social',
      descripcion:
          'Periodismo, comunicación institucional y medios digitales. Producción de contenido en la FM de la universidad.',
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
          'Gestión de personal, reclutamiento, capacitación y legislación laboral. Prácticas en empresas del sur del GBA.',
      area: 'Administración',
      nivel: 'Terciario',
      duracionAnios: 2,
      modalidad: 'Presencial',
      salidaLaboral:
          'Técnico en RRHH, selector de personal, capacitador',
      requisitos: 'Secundario completo',
      tag: 'FECHAS IMPORTANTES',
      aprobada: true,
      createdAt: DateTime(2026, 4, 8),
    ),
    OfertaModel(
      ofertaId: 'oferta_unlz_5',
      institucionUid: 'unlz',
      nombre: 'Licenciatura en Educación',
      descripcion:
          'Formación docente con enfoque en tecnología educativa y pedagogía crítica. Prácticas en escuelas del conurbano.',
      area: 'Educación',
      nivel: 'Universitario',
      duracionAnios: 4,
      modalidad: 'Presencial',
      salidaLaboral: 'Docente, pedagogo, diseñador curricular',
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
          'Programación web, móvil y bases de datos. Proyecto integrador con empresa real en el último semestre.',
      area: 'Tecnología',
      nivel: 'Terciario',
      duracionAnios: 2,
      modalidad: 'Presencial',
      salidaLaboral: 'Desarrollador, programador, tester',
      requisitos: 'Secundario completo. Examen de ingreso en lógica.',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 4, 3),
    ),
  ]);

  // --- UNPAZ (Universidad Nacional de José C. Paz) ---
  batch.set(
    firestore.collection('instituciones').doc('unpaz'),
    InstitucionModel(
      institucionUid: 'unpaz',
      nombre: 'UNPAZ',
      descripcion:
          'La Universidad Nacional de José Clemente Paz, fundada en 2009, es una universidad pública de acceso irrestricto con enfoque interdisciplinario y compromiso social.',
      direccion: 'Leandro N. Alem 4731',
      ciudad: 'José C. Paz',
      provincia: 'Buenos Aires',
      telefono: '(02320) 649025',
      email: 'comunicacion@unpaz.edu.ar',
      sitioWeb: 'https://www.unpaz.edu.ar',
      logoURL: 'https://www.unpaz.edu.ar/sites/default/files/Logo%20Unpaz.png',
      latitud: -34.5204,
      longitud: -58.7456,
      estado: 'aprobada',
      createdAt: DateTime(2025, 6, 1),
    ).toMap(),
    SetOptions(merge: false),
  );

  // --- ISFT 184 (Pilar) ---
  batch.set(
    firestore.collection('instituciones').doc('isft184'),
    InstitucionModel(
      institucionUid: 'isft184',
      nombre: 'ISFT N°184',
      descripcion:
          'Instituto Superior de Formación Técnica Nº 184 "Lic. Jorge Pugliese" de Pilar. Más de 34 años formando profesionales con títulos de validez nacional.',
      direccion: 'Sanguinetti 521',
      ciudad: 'Pilar',
      provincia: 'Buenos Aires',
      telefono: '(0230) 443-5135',
      email: 'isft184oficial@gmail.com',
      sitioWeb: 'https://isft184.wixsite.com/inicio',
      logoURL: 'https://isft184-bue.infd.edu.ar/sitio/wp-content/uploads/2020/10/icono-184.jpg',
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
      nombre: 'ISFT N°182',
      descripcion:
          'Instituto Superior de Formación Técnica Nº 182 "Nos Importa el Mañana" de San Miguel. Ofrece tecnicaturas en Análisis de Sistemas, Enfermería, RRHH y más.',
      direccion: 'Rta. 8 y Avellaneda, Bo. Sgto. Cabral',
      ciudad: 'San Miguel',
      provincia: 'Buenos Aires',
      telefono: '(011) 4667-3993',
      email: '182informes@gmail.com',
      sitioWeb: 'https://isft182.edu.ar',
      logoURL: 'https://isft182-bue.infd.edu.ar/sitio/wp-content/uploads/2018/09/isft182_logo.png',
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
      nombre: 'ISFT N°234',
      descripcion:
          'Instituto Superior de Formación Técnica Nº 234 de Malvinas Argentinas. Carreras bimodales con títulos oficiales avalados por la Dirección General de Cultura y Educación.',
      direccion: '25 de Mayo 3084',
      ciudad: 'Los Polvorines, Malvinas Argentinas',
      provincia: 'Buenos Aires',
      telefono: '(011) 4664-0000',
      email: 'isft234@gmail.com',
      sitioWeb: 'https://isft234.edu.ar',
      logoURL: 'https://isft234.edu.ar/wp-content/uploads/2021/11/INSTITUTO-SUPERIOR-234.png',
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
      nombre: 'Tecnicatura Superior en Administración',
      descripcion:
          'Formación en gestión empresarial, contabilidad y recursos humanos. Títulos de validez nacional.',
      area: 'Administración',
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
      nombre: 'Tecnicatura Superior en Análisis de Sistemas',
      descripcion:
          'Formación en análisis, diseño e implementación de sistemas informáticos. Prácticas en empresas del sector.',
      area: 'Tecnología',
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
      nombre: 'Tecnicatura Superior en Construcción Sustentable',
      descripcion:
          'Formación en construcción con enfoque sustentable, eficiencia energética y materiales ecológicos.',
      area: 'Ingeniería',
      nivel: 'Terciario',
      duracionAnios: 3,
      modalidad: 'Bimodal',
      salidaLaboral: 'Técnico en construcción, proyectista, supervisor de obras',
      requisitos: 'Secundario completo',
      tag: 'NUEVO',
      aprobada: true,
      createdAt: DateTime(2026, 6, 1),
    ),
    OfertaModel(
      ofertaId: 'oferta_unpaz_1',
      institucionUid: 'unpaz',
      nombre: 'Licenciatura en Enfermería',
      descripcion:
          'Formación médica con énfasis en salud pública y atención primaria. Prácticas en hospitales de la zona.',
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
      nombre: 'Abogacía',
      descripcion:
          'Formación en derecho con énfasis en derechos humanos, procesos de integración regional y acceso a la justicia. Clínicas jurídicas gratuitas para la comunidad.',
      area: 'Derecho',
      nivel: 'Universitario',
      duracionAnios: 5,
      modalidad: 'Presencial',
      salidaLaboral: 'Abogado/a, defensor/a público/a, asesor/a legal, mediador/a',
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
          'Formación en intervención social, políticas públicas y trabajo territorial. Prácticas en organizaciones sociales del distrito.',
      area: 'Ciencias Sociales',
      nivel: 'Universitario',
      duracionAnios: 4,
      modalidad: 'Presencial',
      salidaLaboral:
          'Trabajador/a social, gestor/a de políticas, referente territorial',
      requisitos: 'Secundario completo. Ingreso irrestricto.',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 6, 5),
    ),
    OfertaModel(
      ofertaId: 'oferta_unpaz_4',
      institucionUid: 'unpaz',
      nombre: 'Licenciatura en Administración',
      descripcion:
          'Gestión de organizaciones públicas y privadas, economía social y desarrollo local. Proyectos con PyMEs de la región.',
      area: 'Administración',
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
      nombre: 'Licenciatura en Educación',
      descripcion:
          'Formación de profesionales de la educación con enfoque en inclusión, tecnología educativa y políticas de niñez y juventud.',
      area: 'Educación',
      nivel: 'Universitario',
      duracionAnios: 4,
      modalidad: 'Presencial',
      salidaLaboral:
          'Docente, pedagogo/a, diseñador/a curricular, gestor/a educativo/a',
      requisitos: 'Secundario completo. Ingreso irrestricto.',
      tag: 'BECAS',
      aprobada: true,
      createdAt: DateTime(2026, 6, 5),
    ),
    OfertaModel(
      ofertaId: 'oferta_unpaz_6',
      institucionUid: 'unpaz',
      nombre: 'Contador Público',
      descripcion:
          'Formación en contabilidad, auditoría, impuestos y finanzas con perspectiva de desarrollo regional. Prácticas en estudios contables.',
      area: 'Economía',
      nivel: 'Universitario',
      duracionAnios: 5,
      modalidad: 'Presencial',
      salidaLaboral:
          'Contador/a público/a, auditor/a, asesor/a impositivo/a',
      requisitos: 'Secundario completo. Ingreso irrestricto.',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 6, 5),
    ),
    // --- ISFT 182 (San Miguel) ---
    OfertaModel(
      ofertaId: 'oferta_isft182_2',
      institucionUid: 'isft182',
      nombre: 'Tecnicatura Superior en Enfermería',
      descripcion:
          'Formación en cuidados enfermeros con rotaciones hospitalarias y atención primaria de la salud. Enfoque comunitario.',
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
          'Gestión del capital humano: selección, capacitación, liquidación de sueldos y administración de personal.',
      area: 'Administración',
      nivel: 'Terciario',
      duracionAnios: 2,
      modalidad: 'Presencial',
      salidaLaboral:
          'Técnico/a en RRHH, selector/a de personal, capacitador/a, liquidador/a',
      requisitos: 'Secundario completo',
      tag: 'NUEVO',
      aprobada: true,
      createdAt: DateTime(2026, 6, 5),
    ),
    OfertaModel(
      ofertaId: 'oferta_isft182_4',
      institucionUid: 'isft182',
      nombre: 'Tecnicatura Superior en Bibliotecología',
      descripcion:
          'Organización, gestión y difusión de colecciones bibliográficas y recursos de información en bibliotecas, archivos y centros de documentación.',
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
          'Prevención de riesgos laborales, control de condiciones ambientales y confección de planes de evacuación.',
      area: 'Ingeniería',
      nivel: 'Terciario',
      duracionAnios: 2,
      modalidad: 'Presencial',
      salidaLaboral:
          'Técnico/a en higiene y seguridad, asesor/a de prevención, auditor/a',
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
          'Formación para acompañar procesos de aprendizaje y desarrollo personal en ámbitos educativos y organizacionales.',
      area: 'Educación',
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
          'Registración contable, liquidación de impuestos y cierres de ejercicio. Prácticas en estudios contables de la zona.',
      area: 'Economía',
      nivel: 'Terciario',
      duracionAnios: 2,
      modalidad: 'Presencial',
      salidaLaboral:
          'Técnico/a contable, auxiliar impositivo/a, liquidador/a',
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
          'Negocios internacionales, logística, aduana y operaciones de exportación e importación. Simulaciones de comercio exterior.',
      area: 'Administración',
      nivel: 'Terciario',
      duracionAnios: 3,
      modalidad: 'Presencial',
      salidaLaboral:
          'Despachante de aduana, operador/a de comercio exterior, logístico/a',
      requisitos: 'Secundario completo',
      tag: 'NUEVO',
      aprobada: true,
      createdAt: DateTime(2026, 6, 5),
    ),
    OfertaModel(
      ofertaId: 'oferta_isft184_5',
      institucionUid: 'isft184',
      nombre: 'Tecnicatura Superior en Gestión Ambiental',
      descripcion:
          'Gestión de residuos, auditoría ambiental y sustentabilidad en organizaciones. Trabajo de campo en el corredor del Río Luján.',
      area: 'Ciencias Ambientales',
      nivel: 'Terciario',
      duracionAnios: 2,
      modalidad: 'Presencial',
      salidaLaboral:
          'Técnico/a ambiental, auditor/a, gestor/a de residuos',
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
          'Prevención de accidentes laborales y enfermedades profesionales en plantas industriales y obras.',
      area: 'Ingeniería',
      nivel: 'Terciario',
      duracionAnios: 2,
      modalidad: 'Presencial',
      salidaLaboral:
          'Técnico/a en higiene y seguridad, supervisor/a de obra',
      requisitos: 'Secundario completo',
      tag: 'INSCRIPCIONES ABIERTAS',
      aprobada: true,
      createdAt: DateTime(2026, 6, 5),
    ),
    // --- ISFT 234 (Los Polvorines) ---
    OfertaModel(
      ofertaId: 'oferta_isft234_2',
      institucionUid: 'isft234',
      nombre: 'Tecnicatura Superior en Enfermería',
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
      nombre: 'Tecnicatura Superior en Análisis de Sistemas',
      descripcion:
          'Análisis, diseño e implementación de sistemas informáticos. Prácticas profesionalizantes en el polo tecnológico de la zona.',
      area: 'Tecnología',
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
          'Periodismo deportivo en radio, televisión y medios digitales. Relatos, crónicas y coberturas en vivo.',
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
      nombre: 'Tecnicatura Superior en Acompañamiento Terapéutico',
      descripcion:
          'Acompañamiento de personas con padecimientos subjetivos en el marco de equipos interdisciplinarios de salud.',
      area: 'Salud',
      nivel: 'Terciario',
      duracionAnios: 3,
      modalidad: 'Bimodal',
      salidaLaboral:
          'Acompañante terapéutico/a, integrante de equipos de salud',
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
          'Selección, capacitación y administración de personal. Prácticas en empresas del Parque Industrial de Malvinas Argentinas.',
      area: 'Administración',
      nivel: 'Terciario',
      duracionAnios: 2,
      modalidad: 'Bimodal',
      salidaLaboral:
          'Técnico/a en RRHH, selector/a de personal, capacitador/a',
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
      'eliminarIsft180: ${ofertasSnap.docs.length} ofertas y la institución eliminadas');
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
  'usal': 'https://www.usal.edu.ar/images/logo.png',
};

String _normalizarNombre(String nombre) {
  const conAcentos = 'áéíóúüñ';
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

Future<void> seedAvisos() async {
  final firestore = FirebaseFirestore.instance;
  final batch = firestore.batch();

  final avisos = [
    {
      'titulo': 'Inscripciones abiertas 2027',
      'mensaje':
          'Se encuentran abiertas las inscripciones para el ciclo lectivo 2027 en las universidades de la región. Consultá las fechas de cada institución.',
      'tipo': 'inscripcion',
      'link': '/map',
      'publicado': DateTime(2026, 9, 12),
    },
    {
      'titulo': 'Nuevas fechas de ingreso en zona norte',
      'mensaje':
          'Las universidades de la zona norte confirmaron nuevas fechas de ingreso e inscripción. Ingresá y revisá los requisitos por carrera.',
      'tipo': 'noticia',
      'link': '/map',
      'publicado': DateTime(2026, 9, 5),
    },
    {
      'titulo': '¿Todavía no hacés tu test vocacional?',
      'mensaje':
          'Descubrí qué carrera se ajusta a tus intereses con nuestro test vocacional gratuito. Te lleva menos de 5 minutos.',
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
