import 'package:flutter/material.dart';
import 'package:remedi_auth/phone_number_input/models/country_model.dart';
import 'package:remedi_auth/phone_number_input/utils/util.dart';

/// Creates a list of Countries with a search textfield.
class CountrySearchListWidget extends StatefulWidget {
  final List<Country> countries;
  final InputDecoration? searchBoxDecoration;
  final String? locale;
  final ScrollController? scrollController;
  final bool autoFocus;
  final bool? showFlags;
  final bool? useEmoji;
  final Color? color;

  CountrySearchListWidget(
    this.countries,
    this.locale, {
    this.searchBoxDecoration,
    this.scrollController,
    this.showFlags,
    this.useEmoji,
    this.autoFocus = false,
    this.color = Colors.white,
  });

  @override
  _CountrySearchListWidgetState createState() =>
      _CountrySearchListWidgetState();
}

class _CountrySearchListWidgetState extends State<CountrySearchListWidget> {
  TextEditingController _searchController = TextEditingController();
  late List<Country> filteredCountries;

  @override
  void initState() {
    filteredCountries = filterCountries();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Returns [InputDecoration] of the search box
  InputDecoration getSearchBoxDecoration() {
    return widget.searchBoxDecoration ??
        InputDecoration(
          focusColor: Colors.white,
          helperStyle: TextStyle(color: Colors.white),
          hintStyle: TextStyle(color: Colors.grey.shade700),
          suffixStyle: TextStyle(color: Colors.white),
          counterStyle: TextStyle(color: Colors.white),
          errorStyle: TextStyle(color: Colors.white),
          labelStyle: TextStyle(color: Colors.grey.shade700),
          prefixStyle: TextStyle(color: Colors.white),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          labelText: 'Search by country name or dial code',
        );
  }

  /// Filters the list of Country by text from the search box.
  List<Country> filterCountries() {
    final value = _searchController.text.trim();

    if (value.isNotEmpty) {
      return widget.countries
          .where(
            (Country country) =>
                country.alpha3Code!
                    .toLowerCase()
                    .startsWith(value.toLowerCase()) ||
                country.name!.toLowerCase().contains(value.toLowerCase()) ||
                getCountryName(country)!
                    .toLowerCase()
                    .contains(value.toLowerCase()) ||
                country.dialCode!.contains(value.toLowerCase()),
          )
          .toList();
    }

    return widget.countries;
  }

  /// Returns the country name of a [Country]. if the locale is set and translation in available.
  /// returns the translated name.
  String? getCountryName(Country country) {
    if (widget.locale != null && country.nameTranslations != null) {
      String? translated = country.nameTranslations![widget.locale!];
      if (translated != null && translated.isNotEmpty) {
        return translated;
      }
    }
    return country.name;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextFormField(
            style: TextStyle(color: Colors.white),
            cursorColor: Colors.white,
            decoration: getSearchBoxDecoration(),
            controller: _searchController,
            autofocus: widget.autoFocus,
            onChanged: (value) =>
                setState(() => filteredCountries = filterCountries()),
          ),
        ),
        Flexible(
          child: ListView.builder(
            controller: widget.scrollController,
            shrinkWrap: true,
            itemCount: filteredCountries.length,
            itemBuilder: (BuildContext context, int index) {
              Country country = filteredCountries[index];
              return ListTile(
                leading: widget.showFlags!
                    ? _Flag(country: country, useEmoji: widget.useEmoji)
                    : null,
                title: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    '${getCountryName(country)}',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Colors.grey.shade50,
                    ),
                  ),
                ),
                subtitle: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    '${country.dialCode ?? ''}',
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop<Country>(country);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}

class _Flag extends StatelessWidget {
  final Country? country;
  final bool? useEmoji;

  const _Flag({Key? key, this.country, this.useEmoji}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return country != null
        ? Container(
            child: useEmoji!
                ? Text(
                    Utils.generateFlagEmojiUnicode(country?.alpha2Code ?? ''),
                    style: Theme.of(context).textTheme.headlineMedium,
                  )
                : country?.flagUri != null
                    ? CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage: AssetImage(
                          country!.flagUri,
                          package: 'remedi_auth',
                        ),
                      )
                    : SizedBox.shrink(),
          )
        : SizedBox.shrink();
  }
}
