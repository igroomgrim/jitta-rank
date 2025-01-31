# Jitta Rank 📈

#### A Flutter application for viewing and analyzing stock rankings with offline support, implementing Clean Architecture principles and the BLoC pattern for state management.

*⚠️ Jitta Rank **is not an official** Jitta product! ⚠️*

*🚀 Built as a 7-day challenge to push my skills in architecture, state management, and performance optimization. Expect clean code, but maybe also some late-night debugging magic. 🌚✨🐛🌝*

## Overview

Jitta Rank is a mobile application that allows users to:

- View ranked stocks with their performance metrics and Jitta scores

- Search stocks by name and filter by sectors

- View detailed stock information including price history and financial metrics

- Access data offline through local caching

- Real-time network connectivity monitoring

## Features
**Stock Ranking List**
- View ranked stocks with performance metrics
- Search & filter stocks by symbol, name, sector, and market
- Pull-to-refresh for the latest data
- Infinite scroll with lazy loading
- Offline support with local caching
- Error handling with retry options

**Stock Detail**
- Jitta score and financial analysis
- View comprehensive stock information
- Interactive price history graph
- Real-time price updates (when online)
- Offline access to previously loaded data

## Architecture
The application follows Clean Architecture principles with three main layers:

```
lib/
├── core/          		# Shared core functionality
│ ├── error/	 		# Error handling and exceptions
│ ├── navigation/ 		# Navigation management
│ └── networking/ 		# Network services and connectivity
├── features/ 			# Feature modules
│ ├── stock_ranking/ 	# Stock ranking feature
│ │ ├── data/ 			# Data layer (repositories, models, datasources)
│ │ ├── domain/ 		# Business logic (repositories(abstract), entities, usecases)
│ │ └── presentation/ 	# UI layer (screens, widgets, blocs)
│ └── stock_detail/ 	# Stock detail feature
└── main.dart
```

### Data Flow

1. UI triggers events through BLoC/Cubit
2. BLoC executes appropriate use cases
3. Use cases interact with repositories
4. Repository:
   - Checks network connectivity
   - Fetches from GraphQL API if online
   - Falls back to local cache if offline
   - Updates local cache with new data
5. UI updates based on new states from BLoC
