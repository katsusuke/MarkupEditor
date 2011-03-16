/*
 *  Macros.h
 *  CustomTextInputText
 *
 *  Created by t-ohata on 09/09/03.
 *  Copyright 2009 MK System. All rights reserved.
 *
 */

//DEBUG時のみコンソールにログを発行するマクロ　
//[ユーザー定義の設定を追加 >> GCC_PREPROCESSOR_DEFINITIONSを追加し、DEBUGを設定する]が必要
#ifdef DEBUG
#  define LOG_CURRENT_METHOD NSLog(@"%@/%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd))
#  define LOG(fmt, ...) NSLog((@"%s(%d) " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#  define LOG(...) ;
#  define LOG_CURRENT_METHOD ;
#endif

#ifdef DEBUG
#  define ASSERT(exp, msg) if(!(exp)){ \
LOG(msg, nil); \
NSAssert(exp, msg); \
}else{}
#  define ASSERT1(exp, fmt, ...) if(!(exp)){ \
LOG(fmt, ##__VA_ARGS__); \
NSAssert1(exp, fmt, ##__VA_ARGS__); \
}else{}
#else
#  define ASSERT(exp, msg)
#  define ASSERT1(exp, fmt, ...)
#endif

#ifdef DEBUG
#  define P(fmt, exp) NSLog(@ "%s => " fmt, #exp, exp)
#  define PO(exp) NSLog(@ "%s => %@", #exp, exp)
#else
#  define P(fmt, exp)
#  define PO(fmt, exp)
#endif

#ifdef DEBUG
#define RECTLOG(rc)  LOG(@ #rc " x:%f y:%f w:%f h:%f", rc.origin.x, rc.origin.y, rc.size.width, rc.size.height)
#define SIZELOG(sz)  LOG(@ #sz " w:%f h:%f", sz.width, sz.height)
#define POINTLOG(pt) LOG(@ #pt " x:%f y:%f", pt.x, pt.y)
#define TRANSFORMLOG(t) LOG(@ #t " a:%f b:%f c:%f d:%f tx:%f ty:%f", t.a, t.b, t.c, t.d, t.tx, t.ty)
#else
#define RECTLOG(rc)
#define SIZELOG(rc)
#define POINTLOG(pt)
#define TRANSFORMLOG(t)
#endif

#ifdef DEBUG
#define DEAD_CODE NSLog(@"DEAD_CODE %s(%d)", __FILE__, __LINE__)
#else
#define DEAD_CODE 
#endif

//他のマクロ
#define LS(key) [[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:nil]

