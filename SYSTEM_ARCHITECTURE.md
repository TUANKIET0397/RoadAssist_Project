# RoadAssist System Architecture

## Overview
RoadAssist là một ứng dụng cứu hộ xe hai chiều kết nối giữa người dùng cần cứu hộ và các garage cung cấp dịch vụ cứu hộ.

## High-Level Architecture

```mermaid
graph TB
    subgraph "Client Layer"
        UA[User App]
        GA[Garage App]
    end
    
    subgraph "Backend Services"
        FB[Firebase]
        FS[Firestore Database]
        FA[Firebase Auth]
        FST[Firebase Storage]
    end
    
    subgraph "External Services"
        GM[Google Maps API]
        GPS[GPS/Location Services]
    end
    
    UA --> FB
    GA --> FB
    FB --> FS
    FB --> FA
    FB --> FST
    UA --> GM
    GA --> GM
    UA --> GPS
    GA --> GPS
```

## Mobile App Architecture

```mermaid
graph TD
    subgraph "Presentation Layer"
        US[User Screens]
        GS[Garage Screens]
        W[Shared Widgets]
    end
    
    subgraph "Business Logic Layer"
        VM[ViewModels/Providers]
        SM[State Management - Riverpod]
    end
    
    subgraph "Data Layer"
        R[Repositories]
        DS[Data Sources]
        M[Models]
    end
    
    subgraph "Core Layer"
        RT[Routes/Navigation]
        S[Services]
        C[Constants]
        U[Utils]
    end
    
    US --> VM
    GS --> VM
    W --> VM
    VM --> SM
    SM --> R
    R --> DS
    DS --> M
    RT --> US
    RT --> GS
    S --> DS
```

## User Flow Architecture

```mermaid
graph LR
    subgraph "User Journey"
        UR[User Request] --> UW[User Waiting]
        UW --> UT[User Tracking]
        UT --> UC[User Completion]
    end
    
    subgraph "Garage Journey"
        GH[Garage Home] --> GA[Accept Request]
        GA --> GS[Status Updates]
        GS --> GC[Complete Rescue]
    end
    
    subgraph "Shared Data"
        RR[Rescue Request Model]
        RT[Real-time Updates]
    end
    
    UR --> RR
    GA --> RR
    RR --> RT
    RT --> UW
    RT --> UT
    RT --> GH
```

## Data Flow Architecture

```mermaid
graph TB
    subgraph "Firebase Collections"
        UC[users]
        GC[garages]
        RC[rescue_requests]
        HC[history]
    end
    
    subgraph "App State"
        AS[Auth State]
        RS[Request State]
        LS[Location State]
        VS[Vehicle State]
    end
    
    subgraph "UI Updates"
        RT[Real-time Listeners]
        SU[State Updates]
        UR[UI Refresh]
    end
    
    UC --> AS
    GC --> AS
    RC --> RS
    AS --> RT
    RS --> RT
    LS --> RT
    VS --> RT
    RT --> SU
    SU --> UR
```

## Technology Stack

### Frontend
- **Framework**: Flutter
- **Language**: Dart
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **UI Components**: Material Design 3

### Backend
- **Database**: Cloud Firestore
- **Authentication**: Firebase Auth
- **Storage**: Firebase Storage
- **Real-time**: Firestore Streams

### External APIs
- **Maps**: Google Maps API
- **Location**: Geolocator Package
- **Geocoding**: Geocoding Package

## Key Components

### 1. Authentication System
```mermaid
graph LR
    L[Login] --> A[Auth Provider]
    R[Register] --> A
    A --> FA[Firebase Auth]
    FA --> UT[User Type Detection]
    UT --> UN[User Navigation]
    UT --> GN[Garage Navigation]
```

### 2. Request Management
```mermaid
sequenceDiagram
    participant U as User
    participant F as Firestore
    participant G as Garage
    
    U->>F: Create Rescue Request
    F->>G: Notify Available Garages
    G->>F: Accept Request
    F->>U: Notify Accepted
    G->>F: Update Progress Steps
    F->>U: Real-time Updates
    G->>F: Complete Request
    F->>U: Show Completion
```

### 3. Vehicle Management
```mermaid
graph TB
    subgraph "Vehicle System"
        VT[Vehicle Types]
        VM[Vehicle Models]
        VI[Vehicle Images]
        VC[Vehicle Constants]
    end
    
    subgraph "User Features"
        VA[Vehicle Add/Edit]
        VS[Vehicle Selection]
        VD[Vehicle Display]
    end
    
    VC --> VI
    VT --> VC
    VM --> VC
    VA --> VT
    VS --> VM
    VD --> VI
```

## Security Architecture

```mermaid
graph TD
    subgraph "Security Layers"
        FA[Firebase Auth]
        FR[Firestore Rules]
        FS[Firebase Security]
    end
    
    subgraph "Access Control"
        UR[User Roles]
        UP[User Permissions]
        DR[Data Rules]
    end
    
    FA --> UR
    UR --> UP
    UP --> FR
    FR --> DR
    DR --> FS
```

## Performance Considerations

### 1. Real-time Updates
- Firestore streams cho cập nhật realtime
- Optimized listeners để tránh excessive reads
- State caching với Riverpod

### 2. Image Management
- Firebase Storage cho vehicle images
- Local caching cho frequently used images
- Lazy loading cho image galleries

### 3. Location Services
- GPS optimization cho battery efficiency
- Location caching để giảm API calls
- Background location updates khi cần thiết

## Deployment Architecture

```mermaid
graph TB
    subgraph "Development"
        DC[Dev Code]
        DT[Dev Testing]
    end
    
    subgraph "Firebase Project"
        FP[Firebase Project]
        FE[Firebase Environments]
    end
    
    subgraph "Distribution"
        GP[Google Play Store]
        AS[App Store]
        APK[Direct APK]
    end
    
    DC --> DT
    DT --> FP
    FP --> FE
    FE --> GP
    FE --> AS
    FE --> APK
```

## Future Scalability

### Horizontal Scaling
- Microservices architecture preparation
- API Gateway implementation
- Load balancing considerations

### Feature Extensions
- Chat system integration
- Payment gateway
- Rating & review system
- Advanced analytics
- Push notifications

### Performance Optimization
- CDN implementation for images
- Database indexing optimization
- Caching layer implementation
- Background sync capabilities

## Monitoring & Analytics

```mermaid
graph LR
    subgraph "Monitoring"
        FC[Firebase Crashlytics]
        FA[Firebase Analytics]
        FP[Firebase Performance]
    end
    
    subgraph "Metrics"
        UM[User Metrics]
        PM[Performance Metrics]
        EM[Error Metrics]
    end
    
    FC --> EM
    FA --> UM
    FP --> PM
```

---

*This architecture document provides a comprehensive overview of the RoadAssist system design, focusing on maintainability, scalability, and user experience.*