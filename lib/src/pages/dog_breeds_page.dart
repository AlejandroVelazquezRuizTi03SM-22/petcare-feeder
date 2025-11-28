import 'package:flutter/material.dart';
import '../models/dog_breed.dart';
import '../services/dog_api_service.dart';

// --- Constantes de Diseño (Misma paleta) ---
const Color kPrimaryColor = Color(0xFF7E57C2);
const Color kBackgroundColor = Color(0xFFF5F3FA);
const Color kSurfaceColor = Colors.white;
const Color kTextPrimary = Color(0xFF332F3D);
const Color kTextSecondary = Color(0xFF7E7B89);
const Color kAccentLight = Color(0xFFEDE7F6);

class DogBreedsPage extends StatefulWidget {
  const DogBreedsPage({super.key});

  @override
  State<DogBreedsPage> createState() => _DogBreedsPageState();
}

class _DogBreedsPageState extends State<DogBreedsPage> {
  final _service = DogApiService();
  final _searchCtrl = TextEditingController();

  late Future<void> _loadFuture;
  List<DogBreed> _allBreeds = [];
  List<DogBreed> _filteredBreeds = [];

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadBreeds();
    _searchCtrl.addListener(_onSearchChanged);
  }

  Future<void> _loadBreeds() async {
    try {
      final breeds = await _service.getBreeds();
      if (mounted) {
        setState(() {
          _allBreeds = breeds;
          _filteredBreeds = breeds;
        });
      }
    } catch (e) {
      // Manejo de error silencioso o mostrar snackbar
      debugPrint(e.toString());
    }
  }

  void _onSearchChanged() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredBreeds = _allBreeds;
      } else {
        _filteredBreeds = _allBreeds.where((b) {
          final name = b.name.toLowerCase();
          final temperament = b.temperament.toLowerCase();
          final origin = b.origin.toLowerCase();
          return name.contains(query) ||
              temperament.contains(query) ||
              origin.contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: kTextPrimary),
        title: const Text(
          'Enciclopedia Canina',
          style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<void>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              _allBreeds.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: kPrimaryColor),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar datos',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // --- Barra de Búsqueda Estilizada ---
              Container(
                margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryColor.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(color: kTextPrimary),
                  decoration: InputDecoration(
                    hintText: 'Buscar raza, país o temperamento...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: kPrimaryColor,
                    ),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear_rounded,
                              color: Colors.grey,
                            ),
                            onPressed: () => _searchCtrl.clear(),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),

              // --- Lista de Razas ---
              Expanded(
                child: _filteredBreeds.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.pets, size: 60, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              'No encontramos esa raza.',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadBreeds,
                        color: kPrimaryColor,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _filteredBreeds.length,
                          itemBuilder: (context, index) {
                            final breed = _filteredBreeds[index];
                            return _DogBreedCard(breed: breed);
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DogBreedCard extends StatelessWidget {
  final DogBreed breed;

  const _DogBreedCard({required this.breed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DogBreedDetailPage(breed: breed),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Imagen con Hero para animación suave
                Hero(
                  tag: breed
                      .name, // Asegúrate de que el nombre sea único o usa ID
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: kAccentLight,
                      image: breed.imageUrl.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(breed.imageUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: breed.imageUrl.isEmpty
                        ? const Icon(Icons.pets, color: kPrimaryColor, size: 30)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                // Información
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        breed.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: kTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (breed.origin.isNotEmpty &&
                          breed.origin.toLowerCase() != 'no especificado')
                        Row(
                          children: [
                            const Icon(
                              Icons.public,
                              size: 14,
                              color: kPrimaryColor,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                breed.origin,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: kTextSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 6),
                      // Temperamento (solo el primero para no saturar)
                      Text(
                        breed.temperament.split(',').first,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: kTextSecondary.withOpacity(0.8),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DogBreedDetailPage extends StatelessWidget {
  final DogBreed breed;

  const DogBreedDetailPage({super.key, required this.breed});

  @override
  Widget build(BuildContext context) {
    final temperamentTags = breed.temperament.isNotEmpty
        ? breed.temperament.split(',').map((e) => e.trim()).toList()
        : <String>[];

    return Scaffold(
      backgroundColor: kSurfaceColor, // Fondo blanco para detalle
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: kSurfaceColor,
            expandedHeight: 300,
            pinned: true,
            elevation: 0,
            iconTheme: const IconThemeData(color: kPrimaryColor),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: breed.name,
                child: breed.imageUrl.isNotEmpty
                    ? Image.network(breed.imageUrl, fit: BoxFit.cover)
                    : Container(
                        color: kAccentLight,
                        child: const Center(
                          child: Icon(
                            Icons.pets,
                            size: 80,
                            color: kPrimaryColor,
                          ),
                        ),
                      ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              // Efecto de hoja superpuesta
              transform: Matrix4.translationValues(0, -20, 0),
              decoration: const BoxDecoration(
                color: kSurfaceColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      breed.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: kTextPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      breed.group.isEmpty ? 'Grupo desconocido' : breed.group,
                      style: const TextStyle(
                        fontSize: 16,
                        color: kPrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Grid de datos rápidos
                    Row(
                      children: [
                        Expanded(
                          child: _InfoCard(
                            icon: Icons.timer_outlined,
                            label: 'Vida',
                            value: breed.lifeSpan.replaceAll(' years', ' años'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (breed.origin.isNotEmpty)
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.public,
                              label: 'Origen',
                              value: breed.origin,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    if (temperamentTags.isNotEmpty) ...[
                      const Text(
                        'Temperamento',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: kTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: temperamentTags.map((t) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: kAccentLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: kPrimaryColor.withOpacity(0.1),
                              ),
                            ),
                            child: Text(
                              t,
                              style: const TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBackgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: kPrimaryColor, size: 24),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: kTextPrimary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
