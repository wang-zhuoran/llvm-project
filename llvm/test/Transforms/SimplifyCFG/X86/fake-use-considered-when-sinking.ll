; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 5
; RUN: opt -p="simplifycfg<sink-common-insts>" -S < %s | FileCheck %s

;; Verify that fake uses are not ignored when sinking instructions in
;; SimplifyCFG; when a fake use appears in only one incoming block they prevent
;; further sinking, and when identical fake uses appear on both sides they
;; are sunk normally.

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define void @foo(i1 %bool, ptr %p) {
; CHECK-LABEL: define void @foo(
; CHECK-SAME: i1 [[BOOL:%.*]], ptr [[P:%.*]]) {
; CHECK-NEXT:  [[ENTRY:.*:]]
; CHECK-NEXT:    br i1 [[BOOL]], label %[[IF_ELSE:.*]], label %[[IF_THEN:.*]]
; CHECK:       [[COMMON_RET:.*]]:
; CHECK-NEXT:    ret void
; CHECK:       [[IF_THEN]]:
; CHECK-NEXT:    store ptr [[P]], ptr [[P]], align 8
; CHECK-NEXT:    br label %[[COMMON_RET]]
; CHECK:       [[IF_ELSE]]:
; CHECK-NEXT:    store ptr [[P]], ptr [[P]], align 8
; CHECK-NEXT:    notail call void (...) @llvm.fake.use(ptr [[P]])
; CHECK-NEXT:    br label %[[COMMON_RET]]
;
entry:
  br i1 %bool, label %if.else, label %if.then

common.ret:                                       ; preds = %if.else, %if.then
  ret void

if.then:                                          ; preds = %entry
  store ptr %p, ptr %p, align 8
  br label %common.ret

if.else:                                          ; preds = %entry
  store ptr %p, ptr %p, align 8
  notail call void (...) @llvm.fake.use(ptr %p)
  br label %common.ret
}

define void @bar(i1 %bool, ptr %p) {
; CHECK-LABEL: define void @bar(
; CHECK-SAME: i1 [[BOOL:%.*]], ptr [[P:%.*]]) {
; CHECK-NEXT:  [[ENTRY:.*:]]
; CHECK-NEXT:    store ptr [[P]], ptr [[P]], align 8
; CHECK-NEXT:    notail call void (...) @llvm.fake.use(ptr [[P]])
; CHECK-NEXT:    ret void
;
entry:
  br i1 %bool, label %if.else, label %if.then

common.ret:                                       ; preds = %if.else, %if.then
  ret void

if.then:                                          ; preds = %entry
  store ptr %p, ptr %p, align 8
  notail call void (...) @llvm.fake.use(ptr %p)
  br label %common.ret

if.else:                                          ; preds = %entry
  store ptr %p, ptr %p, align 8
  notail call void (...) @llvm.fake.use(ptr %p)
  br label %common.ret
}

