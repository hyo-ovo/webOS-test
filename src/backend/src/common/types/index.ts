// 엔티티 타입 정의

export interface User {
  id: number;
  name: string;
  password_hash: string;
  is_child: boolean;
  created_at: Date;
  updated_at: Date;
}

export interface App {
  id: number;
  name: string;
  img_path: string;
  run_path: string;
}

export interface UserApp {
  id: number;
  user_id: number;
  app_id: number;
  sort_order: number;
}

export interface Memo {
  id: number;
  user_id: number;
  memo_type: 1 | 2 | 3 | 4;
  title: string;
  subtitle: string;
  created_at: Date;
  updated_at: Date;
}

// DTO 타입 정의

export interface SignupRequest {
  name: string;
  password: string;
  isChild: boolean;
}

export interface SignupResponse {
  id: number;
  name: string;
  isChild: boolean;
  createdAt: string;
}

export interface LoginRequest {
  name: string;
  password: string;
}

export interface LoginResponse {
  token: string;
  user: {
    id: number;
    name: string;
    isChild: boolean;
  };
}

export interface MemoResponse {
  id: number;
  memoType: 1 | 2 | 3 | 4;
  title: string;
  subtitle: string;
  createdAt: string;
  updatedAt: string;
}

export interface CreateMemoRequest {
  memoType: 1 | 2 | 3 | 4;
  title: string;
  subtitle: string;
}

export interface UpdateMemoRequest {
  title?: string;
  subtitle?: string;
}

export interface UserAppResponse {
  appId: number;
  name: string;
  imgPath: string;
  runPath: string;
  order: number;
}

export interface UpdateAppOrderRequest {
  apps: Array<{
    id?: number; // 기존 앱이면 id 제공, 새 앱이면 생략
    name: string;
    imgPath: string;
    runPath: string;
  }>;
}
