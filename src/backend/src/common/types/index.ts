// 공통 타입 정의

export interface App {
	id: number;
	app_id: string;
	name: string;
	icon_url: string | null;
	created_at: Date;
}

export interface UserAppOrder {
	id: number;
	user_id: number;
	app_order: string[];
	updated_at: Date;
}

export interface Memo {
	id: number;
	user_id: number;
	title: string;
	content: string;
	created_at: Date;
	updated_at: Date;
}

export interface Favorite {
	id: number;
	user_id: number;
	app_id: string;
	created_at: Date;
}

export interface User {
	id: number;
	username: string;
	face_encoding: string;
	created_at: Date;
	updated_at: Date;
}

export interface UserInfo {
	id: number;
	username: string;
}

export interface AuthResponse {
	token: string;
	user_info: UserInfo;
}
