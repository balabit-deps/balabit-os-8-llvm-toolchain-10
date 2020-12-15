; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt %s -instcombine -S | FileCheck %s

; Given pattern:
;   icmp eq/ne (and ((x shift Q), (y oppositeshift K))), 0
; we should move shifts to the same hand of 'and', i.e. e.g. rewrite as
;   icmp eq/ne (and (((x shift Q) shift K), y)), 0
; We are only interested in opposite logical shifts here.

; Basic scalar test with constants

define i1 @t0_const_lshr_shl_ne(i32 %x, i32 %y) {
; CHECK-LABEL: @t0_const_lshr_shl_ne(
; CHECK-NEXT:    [[TMP1:%.*]] = lshr i32 [[X:%.*]], 2
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], [[Y:%.*]]
; CHECK-NEXT:    [[TMP3:%.*]] = icmp ne i32 [[TMP2]], 0
; CHECK-NEXT:    ret i1 [[TMP3]]
;
  %t0 = lshr i32 %x, 1
  %t1 = shl i32 %y, 1
  %t2 = and i32 %t1, %t0
  %t3 = icmp ne i32 %t2, 0
  ret i1 %t3
}
define i1 @t1_const_shl_lshr_ne(i32 %x, i32 %y) {
; CHECK-LABEL: @t1_const_shl_lshr_ne(
; CHECK-NEXT:    [[TMP1:%.*]] = lshr i32 [[Y:%.*]], 2
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], [[X:%.*]]
; CHECK-NEXT:    [[TMP3:%.*]] = icmp ne i32 [[TMP2]], 0
; CHECK-NEXT:    ret i1 [[TMP3]]
;
  %t0 = shl i32 %x, 1
  %t1 = lshr i32 %y, 1
  %t2 = and i32 %t1, %t0
  %t3 = icmp ne i32 %t2, 0
  ret i1 %t3
}

; We are ok with 'eq' predicate too.
define i1 @t2_const_lshr_shl_eq(i32 %x, i32 %y) {
; CHECK-LABEL: @t2_const_lshr_shl_eq(
; CHECK-NEXT:    [[TMP1:%.*]] = lshr i32 [[X:%.*]], 2
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], [[Y:%.*]]
; CHECK-NEXT:    [[TMP3:%.*]] = icmp eq i32 [[TMP2]], 0
; CHECK-NEXT:    ret i1 [[TMP3]]
;
  %t0 = lshr i32 %x, 1
  %t1 = shl i32 %y, 1
  %t2 = and i32 %t1, %t0
  %t3 = icmp eq i32 %t2, 0
  ret i1 %t3
}

; Basic scalar test with constants after folding

define i1 @t3_const_after_fold_lshr_shl_ne(i32 %x, i32 %y, i32 %len) {
; CHECK-LABEL: @t3_const_after_fold_lshr_shl_ne(
; CHECK-NEXT:    [[TMP1:%.*]] = lshr i32 [[X:%.*]], 31
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], [[Y:%.*]]
; CHECK-NEXT:    [[TMP3:%.*]] = icmp ne i32 [[TMP2]], 0
; CHECK-NEXT:    ret i1 [[TMP3]]
;
  %t0 = sub i32 32, %len
  %t1 = lshr i32 %x, %t0
  %t2 = add i32 %len, -1
  %t3 = shl i32 %y, %t2
  %t4 = and i32 %t1, %t3
  %t5 = icmp ne i32 %t4, 0
  ret i1 %t5
}
define i1 @t4_const_after_fold_lshr_shl_ne(i32 %x, i32 %y, i32 %len) {
; CHECK-LABEL: @t4_const_after_fold_lshr_shl_ne(
; CHECK-NEXT:    [[TMP1:%.*]] = lshr i32 [[Y:%.*]], 31
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], [[X:%.*]]
; CHECK-NEXT:    [[TMP3:%.*]] = icmp ne i32 [[TMP2]], 0
; CHECK-NEXT:    ret i1 [[TMP3]]
;
  %t0 = sub i32 32, %len
  %t1 = shl i32 %x, %t0
  %t2 = add i32 %len, -1
  %t3 = lshr i32 %y, %t2
  %t4 = and i32 %t1, %t3
  %t5 = icmp ne i32 %t4, 0
  ret i1 %t5
}

; Completely variable shift amounts

define i1 @t5_const_lshr_shl_ne(i32 %x, i32 %y, i32 %shamt0, i32 %shamt1) {
; CHECK-LABEL: @t5_const_lshr_shl_ne(
; CHECK-NEXT:    [[T0:%.*]] = lshr i32 [[X:%.*]], [[SHAMT0:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = shl i32 [[Y:%.*]], [[SHAMT1:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = and i32 [[T1]], [[T0]]
; CHECK-NEXT:    [[T3:%.*]] = icmp ne i32 [[T2]], 0
; CHECK-NEXT:    ret i1 [[T3]]
;
  %t0 = lshr i32 %x, %shamt0
  %t1 = shl i32 %y, %shamt1
  %t2 = and i32 %t1, %t0
  %t3 = icmp ne i32 %t2, 0
  ret i1 %t3
}
define i1 @t6_const_shl_lshr_ne(i32 %x, i32 %y, i32 %shamt0, i32 %shamt1) {
; CHECK-LABEL: @t6_const_shl_lshr_ne(
; CHECK-NEXT:    [[T0:%.*]] = shl i32 [[X:%.*]], [[SHAMT0:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = lshr i32 [[Y:%.*]], [[SHAMT1:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = and i32 [[T1]], [[T0]]
; CHECK-NEXT:    [[T3:%.*]] = icmp ne i32 [[T2]], 0
; CHECK-NEXT:    ret i1 [[T3]]
;
  %t0 = shl i32 %x, %shamt0
  %t1 = lshr i32 %y, %shamt1
  %t2 = and i32 %t1, %t0
  %t3 = icmp ne i32 %t2, 0
  ret i1 %t3
}

; Very basic vector tests

define <2 x i1> @t7_const_lshr_shl_ne_vec_splat(<2 x i32> %x, <2 x i32> %y) {
; CHECK-LABEL: @t7_const_lshr_shl_ne_vec_splat(
; CHECK-NEXT:    [[TMP1:%.*]] = lshr <2 x i32> [[X:%.*]], <i32 2, i32 2>
; CHECK-NEXT:    [[TMP2:%.*]] = and <2 x i32> [[TMP1]], [[Y:%.*]]
; CHECK-NEXT:    [[TMP3:%.*]] = icmp ne <2 x i32> [[TMP2]], zeroinitializer
; CHECK-NEXT:    ret <2 x i1> [[TMP3]]
;
  %t0 = lshr <2 x i32> %x, <i32 1, i32 1>
  %t1 = shl <2 x i32> %y, <i32 1, i32 1>
  %t2 = and <2 x i32> %t1, %t0
  %t3 = icmp ne <2 x i32> %t2, <i32 0, i32 0>
  ret <2 x i1> %t3
}
define <2 x i1> @t8_const_lshr_shl_ne_vec_nonsplat(<2 x i32> %x, <2 x i32> %y) {
; CHECK-LABEL: @t8_const_lshr_shl_ne_vec_nonsplat(
; CHECK-NEXT:    [[TMP1:%.*]] = lshr <2 x i32> [[X:%.*]], <i32 4, i32 6>
; CHECK-NEXT:    [[TMP2:%.*]] = and <2 x i32> [[TMP1]], [[Y:%.*]]
; CHECK-NEXT:    [[TMP3:%.*]] = icmp ne <2 x i32> [[TMP2]], zeroinitializer
; CHECK-NEXT:    ret <2 x i1> [[TMP3]]
;
  %t0 = lshr <2 x i32> %x, <i32 1, i32 2>
  %t1 = shl <2 x i32> %y, <i32 3, i32 4>
  %t2 = and <2 x i32> %t1, %t0
  %t3 = icmp ne <2 x i32> %t2, <i32 0, i32 0>
  ret <2 x i1> %t3
}
define <3 x i1> @t9_const_lshr_shl_ne_vec_undef0(<3 x i32> %x, <3 x i32> %y) {
; CHECK-LABEL: @t9_const_lshr_shl_ne_vec_undef0(
; CHECK-NEXT:    [[TMP1:%.*]] = lshr <3 x i32> [[X:%.*]], <i32 2, i32 undef, i32 2>
; CHECK-NEXT:    [[TMP2:%.*]] = and <3 x i32> [[TMP1]], [[Y:%.*]]
; CHECK-NEXT:    [[TMP3:%.*]] = icmp ne <3 x i32> [[TMP2]], zeroinitializer
; CHECK-NEXT:    ret <3 x i1> [[TMP3]]
;
  %t0 = lshr <3 x i32> %x, <i32 1, i32 undef, i32 1>
  %t1 = shl <3 x i32> %y, <i32 1, i32 1, i32 1>
  %t2 = and <3 x i32> %t1, %t0
  %t3 = icmp ne <3 x i32> %t2, <i32 0, i32 0, i32 0>
  ret <3 x i1> %t3
}
define <3 x i1> @t10_const_lshr_shl_ne_vec_undef1(<3 x i32> %x, <3 x i32> %y) {
; CHECK-LABEL: @t10_const_lshr_shl_ne_vec_undef1(
; CHECK-NEXT:    [[TMP1:%.*]] = lshr <3 x i32> [[X:%.*]], <i32 2, i32 undef, i32 2>
; CHECK-NEXT:    [[TMP2:%.*]] = and <3 x i32> [[TMP1]], [[Y:%.*]]
; CHECK-NEXT:    [[TMP3:%.*]] = icmp ne <3 x i32> [[TMP2]], zeroinitializer
; CHECK-NEXT:    ret <3 x i1> [[TMP3]]
;
  %t0 = lshr <3 x i32> %x, <i32 1, i32 1, i32 1>
  %t1 = shl <3 x i32> %y, <i32 1, i32 undef, i32 1>
  %t2 = and <3 x i32> %t1, %t0
  %t3 = icmp ne <3 x i32> %t2, <i32 0, i32 0, i32 0>
  ret <3 x i1> %t3
}
define <3 x i1> @t11_const_lshr_shl_ne_vec_undef2(<3 x i32> %x, <3 x i32> %y) {
; CHECK-LABEL: @t11_const_lshr_shl_ne_vec_undef2(
; CHECK-NEXT:    [[TMP1:%.*]] = lshr <3 x i32> [[X:%.*]], <i32 2, i32 2, i32 2>
; CHECK-NEXT:    [[TMP2:%.*]] = and <3 x i32> [[TMP1]], [[Y:%.*]]
; CHECK-NEXT:    [[TMP3:%.*]] = icmp ne <3 x i32> [[TMP2]], zeroinitializer
; CHECK-NEXT:    ret <3 x i1> [[TMP3]]
;
  %t0 = lshr <3 x i32> %x, <i32 1, i32 1, i32 1>
  %t1 = shl <3 x i32> %y, <i32 1, i32 1, i32 1>
  %t2 = and <3 x i32> %t1, %t0
  %t3 = icmp ne <3 x i32> %t2, <i32 0, i32 undef, i32 0>
  ret <3 x i1> %t3
}
define <3 x i1> @t12_const_lshr_shl_ne_vec_undef3(<3 x i32> %x, <3 x i32> %y) {
; CHECK-LABEL: @t12_const_lshr_shl_ne_vec_undef3(
; CHECK-NEXT:    [[TMP1:%.*]] = lshr <3 x i32> [[X:%.*]], <i32 2, i32 undef, i32 2>
; CHECK-NEXT:    [[TMP2:%.*]] = and <3 x i32> [[TMP1]], [[Y:%.*]]
; CHECK-NEXT:    [[TMP3:%.*]] = icmp ne <3 x i32> [[TMP2]], zeroinitializer
; CHECK-NEXT:    ret <3 x i1> [[TMP3]]
;
  %t0 = lshr <3 x i32> %x, <i32 1, i32 undef, i32 1>
  %t1 = shl <3 x i32> %y, <i32 1, i32 undef, i32 1>
  %t2 = and <3 x i32> %t1, %t0
  %t3 = icmp ne <3 x i32> %t2, <i32 0, i32 0, i32 0>
  ret <3 x i1> %t3
}
define <3 x i1> @t13_const_lshr_shl_ne_vec_undef4(<3 x i32> %x, <3 x i32> %y) {
; CHECK-LABEL: @t13_const_lshr_shl_ne_vec_undef4(
; CHECK-NEXT:    [[TMP1:%.*]] = lshr <3 x i32> [[X:%.*]], <i32 2, i32 undef, i32 2>
; CHECK-NEXT:    [[TMP2:%.*]] = and <3 x i32> [[TMP1]], [[Y:%.*]]
; CHECK-NEXT:    [[TMP3:%.*]] = icmp ne <3 x i32> [[TMP2]], zeroinitializer
; CHECK-NEXT:    ret <3 x i1> [[TMP3]]
;
  %t0 = lshr <3 x i32> %x, <i32 1, i32 1, i32 1>
  %t1 = shl <3 x i32> %y, <i32 1, i32 undef, i32 1>
  %t2 = and <3 x i32> %t1, %t0
  %t3 = icmp ne <3 x i32> %t2, <i32 0, i32 undef, i32 0>
  ret <3 x i1> %t3
}
define <3 x i1> @t14_const_lshr_shl_ne_vec_undef5(<3 x i32> %x, <3 x i32> %y) {
; CHECK-LABEL: @t14_const_lshr_shl_ne_vec_undef5(
; CHECK-NEXT:    [[TMP1:%.*]] = lshr <3 x i32> [[X:%.*]], <i32 2, i32 undef, i32 2>
; CHECK-NEXT:    [[TMP2:%.*]] = and <3 x i32> [[TMP1]], [[Y:%.*]]
; CHECK-NEXT:    [[TMP3:%.*]] = icmp ne <3 x i32> [[TMP2]], zeroinitializer
; CHECK-NEXT:    ret <3 x i1> [[TMP3]]
;
  %t0 = lshr <3 x i32> %x, <i32 1, i32 undef, i32 1>
  %t1 = shl <3 x i32> %y, <i32 1, i32 1, i32 1>
  %t2 = and <3 x i32> %t1, %t0
  %t3 = icmp ne <3 x i32> %t2, <i32 0, i32 undef, i32 0>
  ret <3 x i1> %t3
}
define <3 x i1> @t15_const_lshr_shl_ne_vec_undef6(<3 x i32> %x, <3 x i32> %y) {
; CHECK-LABEL: @t15_const_lshr_shl_ne_vec_undef6(
; CHECK-NEXT:    [[TMP1:%.*]] = lshr <3 x i32> [[X:%.*]], <i32 2, i32 undef, i32 2>
; CHECK-NEXT:    [[TMP2:%.*]] = and <3 x i32> [[TMP1]], [[Y:%.*]]
; CHECK-NEXT:    [[TMP3:%.*]] = icmp ne <3 x i32> [[TMP2]], zeroinitializer
; CHECK-NEXT:    ret <3 x i1> [[TMP3]]
;
  %t0 = lshr <3 x i32> %x, <i32 1, i32 undef, i32 1>
  %t1 = shl <3 x i32> %y, <i32 1, i32 undef, i32 1>
  %t2 = and <3 x i32> %t1, %t0
  %t3 = icmp ne <3 x i32> %t2, <i32 0, i32 undef, i32 0>
  ret <3 x i1> %t3
}

; Commutativity tests

declare i32 @gen32()

define i1 @t16_commutativity0(i32 %x) {
; CHECK-LABEL: @t16_commutativity0(
; CHECK-NEXT:    [[Y:%.*]] = call i32 @gen32()
; CHECK-NEXT:    [[TMP1:%.*]] = lshr i32 [[X:%.*]], 2
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], [[Y]]
; CHECK-NEXT:    [[TMP3:%.*]] = icmp ne i32 [[TMP2]], 0
; CHECK-NEXT:    ret i1 [[TMP3]]
;
  %y = call i32 @gen32()
  %t0 = lshr i32 %x, 1
  %t1 = shl i32 %y, 1
  %t2 = and i32 %t1, %t0
  %t3 = icmp ne i32 %t2, 0
  ret i1 %t3
}

define i1 @t17_commutativity1(i32 %y) {
; CHECK-LABEL: @t17_commutativity1(
; CHECK-NEXT:    [[X:%.*]] = call i32 @gen32()
; CHECK-NEXT:    [[TMP1:%.*]] = lshr i32 [[X]], 2
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], [[Y:%.*]]
; CHECK-NEXT:    [[TMP3:%.*]] = icmp ne i32 [[TMP2]], 0
; CHECK-NEXT:    ret i1 [[TMP3]]
;
  %x = call i32 @gen32()
  %t0 = lshr i32 %x, 1
  %t1 = shl i32 %y, 1
  %t2 = and i32 %t0, %t1 ; "swapped"
  %t3 = icmp ne i32 %t2, 0
  ret i1 %t3
}

; One-use tests

declare void @use32(i32)

define i1 @t18_const_oneuse0(i32 %x, i32 %y) {
; CHECK-LABEL: @t18_const_oneuse0(
; CHECK-NEXT:    [[T0:%.*]] = lshr i32 [[X:%.*]], 1
; CHECK-NEXT:    call void @use32(i32 [[T0]])
; CHECK-NEXT:    [[TMP1:%.*]] = lshr i32 [[X]], 2
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], [[Y:%.*]]
; CHECK-NEXT:    [[TMP3:%.*]] = icmp ne i32 [[TMP2]], 0
; CHECK-NEXT:    ret i1 [[TMP3]]
;
  %t0 = lshr i32 %x, 1
  call void @use32(i32 %t0)
  %t1 = shl i32 %y, 1
  %t2 = and i32 %t1, %t0
  %t3 = icmp ne i32 %t2, 0
  ret i1 %t3
}
define i1 @t19_const_oneuse1(i32 %x, i32 %y) {
; CHECK-LABEL: @t19_const_oneuse1(
; CHECK-NEXT:    [[T1:%.*]] = shl i32 [[Y:%.*]], 1
; CHECK-NEXT:    call void @use32(i32 [[T1]])
; CHECK-NEXT:    [[TMP1:%.*]] = lshr i32 [[X:%.*]], 2
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], [[Y]]
; CHECK-NEXT:    [[TMP3:%.*]] = icmp ne i32 [[TMP2]], 0
; CHECK-NEXT:    ret i1 [[TMP3]]
;
  %t0 = lshr i32 %x, 1
  %t1 = shl i32 %y, 1
  call void @use32(i32 %t1)
  %t2 = and i32 %t1, %t0
  %t3 = icmp ne i32 %t2, 0
  ret i1 %t3
}
define i1 @t20_const_oneuse2(i32 %x, i32 %y) {
; CHECK-LABEL: @t20_const_oneuse2(
; CHECK-NEXT:    [[T0:%.*]] = lshr i32 [[X:%.*]], 1
; CHECK-NEXT:    [[T1:%.*]] = shl i32 [[Y:%.*]], 1
; CHECK-NEXT:    [[T2:%.*]] = and i32 [[T1]], [[T0]]
; CHECK-NEXT:    call void @use32(i32 [[T2]])
; CHECK-NEXT:    [[T3:%.*]] = icmp ne i32 [[T2]], 0
; CHECK-NEXT:    ret i1 [[T3]]
;
  %t0 = lshr i32 %x, 1
  %t1 = shl i32 %y, 1
  %t2 = and i32 %t1, %t0
  call void @use32(i32 %t2)
  %t3 = icmp ne i32 %t2, 0
  ret i1 %t3
}
define i1 @t21_const_oneuse3(i32 %x, i32 %y) {
; CHECK-LABEL: @t21_const_oneuse3(
; CHECK-NEXT:    [[T0:%.*]] = lshr i32 [[X:%.*]], 1
; CHECK-NEXT:    call void @use32(i32 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = shl i32 [[Y:%.*]], 1
; CHECK-NEXT:    call void @use32(i32 [[T1]])
; CHECK-NEXT:    [[T2:%.*]] = and i32 [[T1]], [[T0]]
; CHECK-NEXT:    [[T3:%.*]] = icmp ne i32 [[T2]], 0
; CHECK-NEXT:    ret i1 [[T3]]
;
  %t0 = lshr i32 %x, 1
  call void @use32(i32 %t0)
  %t1 = shl i32 %y, 1
  call void @use32(i32 %t1)
  %t2 = and i32 %t1, %t0
  %t3 = icmp ne i32 %t2, 0
  ret i1 %t3
}
define i1 @t22_const_oneuse4(i32 %x, i32 %y) {
; CHECK-LABEL: @t22_const_oneuse4(
; CHECK-NEXT:    [[T0:%.*]] = lshr i32 [[X:%.*]], 1
; CHECK-NEXT:    call void @use32(i32 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = shl i32 [[Y:%.*]], 1
; CHECK-NEXT:    [[T2:%.*]] = and i32 [[T1]], [[T0]]
; CHECK-NEXT:    call void @use32(i32 [[T2]])
; CHECK-NEXT:    [[T3:%.*]] = icmp ne i32 [[T2]], 0
; CHECK-NEXT:    ret i1 [[T3]]
;
  %t0 = lshr i32 %x, 1
  call void @use32(i32 %t0)
  %t1 = shl i32 %y, 1
  %t2 = and i32 %t1, %t0
  call void @use32(i32 %t2)
  %t3 = icmp ne i32 %t2, 0
  ret i1 %t3
}
define i1 @t23_const_oneuse5(i32 %x, i32 %y) {
; CHECK-LABEL: @t23_const_oneuse5(
; CHECK-NEXT:    [[T0:%.*]] = lshr i32 [[X:%.*]], 1
; CHECK-NEXT:    [[T1:%.*]] = shl i32 [[Y:%.*]], 1
; CHECK-NEXT:    call void @use32(i32 [[T1]])
; CHECK-NEXT:    [[T2:%.*]] = and i32 [[T1]], [[T0]]
; CHECK-NEXT:    call void @use32(i32 [[T2]])
; CHECK-NEXT:    [[T3:%.*]] = icmp ne i32 [[T2]], 0
; CHECK-NEXT:    ret i1 [[T3]]
;
  %t0 = lshr i32 %x, 1
  %t1 = shl i32 %y, 1
  call void @use32(i32 %t1)
  %t2 = and i32 %t1, %t0
  call void @use32(i32 %t2)
  %t3 = icmp ne i32 %t2, 0
  ret i1 %t3
}
define i1 @t24_const_oneuse6(i32 %x, i32 %y) {
; CHECK-LABEL: @t24_const_oneuse6(
; CHECK-NEXT:    [[T0:%.*]] = lshr i32 [[X:%.*]], 1
; CHECK-NEXT:    call void @use32(i32 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = shl i32 [[Y:%.*]], 1
; CHECK-NEXT:    call void @use32(i32 [[T1]])
; CHECK-NEXT:    [[T2:%.*]] = and i32 [[T1]], [[T0]]
; CHECK-NEXT:    call void @use32(i32 [[T2]])
; CHECK-NEXT:    [[T3:%.*]] = icmp ne i32 [[T2]], 0
; CHECK-NEXT:    ret i1 [[T3]]
;
  %t0 = lshr i32 %x, 1
  call void @use32(i32 %t0)
  %t1 = shl i32 %y, 1
  call void @use32(i32 %t1)
  %t2 = and i32 %t1, %t0
  call void @use32(i32 %t2)
  %t3 = icmp ne i32 %t2, 0
  ret i1 %t3
}

define i1 @t25_var_oneuse0(i32 %x, i32 %y, i32 %shamt0, i32 %shamt1) {
; CHECK-LABEL: @t25_var_oneuse0(
; CHECK-NEXT:    [[T0:%.*]] = lshr i32 [[X:%.*]], [[SHAMT0:%.*]]
; CHECK-NEXT:    call void @use32(i32 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = shl i32 [[Y:%.*]], [[SHAMT1:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = and i32 [[T1]], [[T0]]
; CHECK-NEXT:    [[T3:%.*]] = icmp ne i32 [[T2]], 0
; CHECK-NEXT:    ret i1 [[T3]]
;
  %t0 = lshr i32 %x, %shamt0
  call void @use32(i32 %t0)
  %t1 = shl i32 %y, %shamt1
  %t2 = and i32 %t1, %t0
  %t3 = icmp ne i32 %t2, 0
  ret i1 %t3
}
define i1 @t26_var_oneuse1(i32 %x, i32 %y, i32 %shamt0, i32 %shamt1) {
; CHECK-LABEL: @t26_var_oneuse1(
; CHECK-NEXT:    [[T0:%.*]] = lshr i32 [[X:%.*]], [[SHAMT0:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = shl i32 [[Y:%.*]], [[SHAMT1:%.*]]
; CHECK-NEXT:    call void @use32(i32 [[T1]])
; CHECK-NEXT:    [[T2:%.*]] = and i32 [[T1]], [[T0]]
; CHECK-NEXT:    [[T3:%.*]] = icmp ne i32 [[T2]], 0
; CHECK-NEXT:    ret i1 [[T3]]
;
  %t0 = lshr i32 %x, %shamt0
  %t1 = shl i32 %y, %shamt1
  call void @use32(i32 %t1)
  %t2 = and i32 %t1, %t0
  %t3 = icmp ne i32 %t2, 0
  ret i1 %t3
}
define i1 @t27_var_oneuse2(i32 %x, i32 %y, i32 %shamt0, i32 %shamt1) {
; CHECK-LABEL: @t27_var_oneuse2(
; CHECK-NEXT:    [[T0:%.*]] = lshr i32 [[X:%.*]], [[SHAMT0:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = shl i32 [[Y:%.*]], [[SHAMT1:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = and i32 [[T1]], [[T0]]
; CHECK-NEXT:    call void @use32(i32 [[T2]])
; CHECK-NEXT:    [[T3:%.*]] = icmp ne i32 [[T2]], 0
; CHECK-NEXT:    ret i1 [[T3]]
;
  %t0 = lshr i32 %x, %shamt0
  %t1 = shl i32 %y, %shamt1
  %t2 = and i32 %t1, %t0
  call void @use32(i32 %t2)
  %t3 = icmp ne i32 %t2, 0
  ret i1 %t3
}
define i1 @t28_var_oneuse3(i32 %x, i32 %y, i32 %shamt0, i32 %shamt1) {
; CHECK-LABEL: @t28_var_oneuse3(
; CHECK-NEXT:    [[T0:%.*]] = lshr i32 [[X:%.*]], [[SHAMT0:%.*]]
; CHECK-NEXT:    call void @use32(i32 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = shl i32 [[Y:%.*]], [[SHAMT1:%.*]]
; CHECK-NEXT:    call void @use32(i32 [[T1]])
; CHECK-NEXT:    [[T2:%.*]] = and i32 [[T1]], [[T0]]
; CHECK-NEXT:    [[T3:%.*]] = icmp ne i32 [[T2]], 0
; CHECK-NEXT:    ret i1 [[T3]]
;
  %t0 = lshr i32 %x, %shamt0
  call void @use32(i32 %t0)
  %t1 = shl i32 %y, %shamt1
  call void @use32(i32 %t1)
  %t2 = and i32 %t1, %t0
  %t3 = icmp ne i32 %t2, 0
  ret i1 %t3
}
define i1 @t29_var_oneuse4(i32 %x, i32 %y, i32 %shamt0, i32 %shamt1) {
; CHECK-LABEL: @t29_var_oneuse4(
; CHECK-NEXT:    [[T0:%.*]] = lshr i32 [[X:%.*]], [[SHAMT0:%.*]]
; CHECK-NEXT:    call void @use32(i32 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = shl i32 [[Y:%.*]], [[SHAMT1:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = and i32 [[T1]], [[T0]]
; CHECK-NEXT:    call void @use32(i32 [[T2]])
; CHECK-NEXT:    [[T3:%.*]] = icmp ne i32 [[T2]], 0
; CHECK-NEXT:    ret i1 [[T3]]
;
  %t0 = lshr i32 %x, %shamt0
  call void @use32(i32 %t0)
  %t1 = shl i32 %y, %shamt1
  %t2 = and i32 %t1, %t0
  call void @use32(i32 %t2)
  %t3 = icmp ne i32 %t2, 0
  ret i1 %t3
}
define i1 @t30_var_oneuse5(i32 %x, i32 %y, i32 %shamt0, i32 %shamt1) {
; CHECK-LABEL: @t30_var_oneuse5(
; CHECK-NEXT:    [[T0:%.*]] = lshr i32 [[X:%.*]], [[SHAMT0:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = shl i32 [[Y:%.*]], [[SHAMT1:%.*]]
; CHECK-NEXT:    call void @use32(i32 [[T1]])
; CHECK-NEXT:    [[T2:%.*]] = and i32 [[T1]], [[T0]]
; CHECK-NEXT:    call void @use32(i32 [[T2]])
; CHECK-NEXT:    [[T3:%.*]] = icmp ne i32 [[T2]], 0
; CHECK-NEXT:    ret i1 [[T3]]
;
  %t0 = lshr i32 %x, %shamt0
  %t1 = shl i32 %y, %shamt1
  call void @use32(i32 %t1)
  %t2 = and i32 %t1, %t0
  call void @use32(i32 %t2)
  %t3 = icmp ne i32 %t2, 0
  ret i1 %t3
}
define i1 @t31_var_oneuse6(i32 %x, i32 %y, i32 %shamt0, i32 %shamt1) {
; CHECK-LABEL: @t31_var_oneuse6(
; CHECK-NEXT:    [[T0:%.*]] = lshr i32 [[X:%.*]], [[SHAMT0:%.*]]
; CHECK-NEXT:    call void @use32(i32 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = shl i32 [[Y:%.*]], [[SHAMT1:%.*]]
; CHECK-NEXT:    call void @use32(i32 [[T1]])
; CHECK-NEXT:    [[T2:%.*]] = and i32 [[T1]], [[T0]]
; CHECK-NEXT:    call void @use32(i32 [[T2]])
; CHECK-NEXT:    [[T3:%.*]] = icmp ne i32 [[T2]], 0
; CHECK-NEXT:    ret i1 [[T3]]
;
  %t0 = lshr i32 %x, %shamt0
  call void @use32(i32 %t0)
  %t1 = shl i32 %y, %shamt1
  call void @use32(i32 %t1)
  %t2 = and i32 %t1, %t0
  call void @use32(i32 %t2)
  %t3 = icmp ne i32 %t2, 0
  ret i1 %t3
}

; Shift-of-const

; Ok, non-truncated shift is of constant;
define i1 @t32_shift_of_const_oneuse0(i32 %x, i32 %y, i32 %len) {
; CHECK-LABEL: @t32_shift_of_const_oneuse0(
; CHECK-NEXT:    [[T0:%.*]] = sub i32 32, [[LEN:%.*]]
; CHECK-NEXT:    call void @use32(i32 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = lshr i32 -52543054, [[T0]]
; CHECK-NEXT:    call void @use32(i32 [[T1]])
; CHECK-NEXT:    [[T2:%.*]] = add i32 [[LEN]], -1
; CHECK-NEXT:    call void @use32(i32 [[T2]])
; CHECK-NEXT:    [[T3:%.*]] = shl i32 [[Y:%.*]], [[T2]]
; CHECK-NEXT:    call void @use32(i32 [[T3]])
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 [[Y]], 1
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ne i32 [[TMP1]], 0
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %t0 = sub i32 32, %len
  call void @use32(i32 %t0)
  %t1 = lshr i32 4242424242, %t0 ; shift-of-constant
  call void @use32(i32 %t1)
  %t2 = add i32 %len, -1
  call void @use32(i32 %t2)
  %t3 = shl i32 %y, %t2
  call void @use32(i32 %t3)
  %t4 = and i32 %t1, %t3 ; no extra uses
  %t5 = icmp ne i32 %t4, 0
  ret i1 %t5
}
; Ok, truncated shift is of constant;
define i1 @t33_shift_of_const_oneuse1(i32 %x, i32 %y, i32 %len) {
; CHECK-LABEL: @t33_shift_of_const_oneuse1(
; CHECK-NEXT:    [[T0:%.*]] = sub i32 32, [[LEN:%.*]]
; CHECK-NEXT:    call void @use32(i32 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = lshr i32 [[X:%.*]], [[T0]]
; CHECK-NEXT:    call void @use32(i32 [[T1]])
; CHECK-NEXT:    [[T2:%.*]] = add i32 [[LEN]], -1
; CHECK-NEXT:    call void @use32(i32 [[T2]])
; CHECK-NEXT:    [[T3:%.*]] = shl i32 -52543054, [[T2]]
; CHECK-NEXT:    call void @use32(i32 [[T3]])
; CHECK-NEXT:    ret i1 false
;
  %t0 = sub i32 32, %len
  call void @use32(i32 %t0)
  %t1 = lshr i32 %x, %t0 ; shift-of-constant
  call void @use32(i32 %t1)
  %t2 = add i32 %len, -1
  call void @use32(i32 %t2)
  %t3 = shl i32 4242424242, %t2
  call void @use32(i32 %t3)
  %t4 = and i32 %t1, %t3 ; no extra uses
  %t5 = icmp ne i32 %t4, 0
  ret i1 %t5
}

; Commutativity with extra uses

define i1 @t34_commutativity0_oneuse0(i32 %x) {
; CHECK-LABEL: @t34_commutativity0_oneuse0(
; CHECK-NEXT:    [[Y:%.*]] = call i32 @gen32()
; CHECK-NEXT:    [[T0:%.*]] = lshr i32 [[X:%.*]], 1
; CHECK-NEXT:    call void @use32(i32 [[T0]])
; CHECK-NEXT:    [[TMP1:%.*]] = lshr i32 [[X]], 2
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], [[Y]]
; CHECK-NEXT:    [[TMP3:%.*]] = icmp ne i32 [[TMP2]], 0
; CHECK-NEXT:    ret i1 [[TMP3]]
;
  %y = call i32 @gen32()
  %t0 = lshr i32 %x, 1
  call void @use32(i32 %t0)
  %t1 = shl i32 %y, 1
  %t2 = and i32 %t1, %t0
  %t3 = icmp ne i32 %t2, 0
  ret i1 %t3
}
define i1 @t35_commutativity0_oneuse1(i32 %x) {
; CHECK-LABEL: @t35_commutativity0_oneuse1(
; CHECK-NEXT:    [[Y:%.*]] = call i32 @gen32()
; CHECK-NEXT:    [[T1:%.*]] = shl i32 [[Y]], 1
; CHECK-NEXT:    call void @use32(i32 [[T1]])
; CHECK-NEXT:    [[TMP1:%.*]] = lshr i32 [[X:%.*]], 2
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], [[Y]]
; CHECK-NEXT:    [[TMP3:%.*]] = icmp ne i32 [[TMP2]], 0
; CHECK-NEXT:    ret i1 [[TMP3]]
;
  %y = call i32 @gen32()
  %t0 = lshr i32 %x, 1
  %t1 = shl i32 %y, 1
  call void @use32(i32 %t1)
  %t2 = and i32 %t1, %t0
  %t3 = icmp ne i32 %t2, 0
  ret i1 %t3
}

define i1 @t36_commutativity1_oneuse0(i32 %y) {
; CHECK-LABEL: @t36_commutativity1_oneuse0(
; CHECK-NEXT:    [[X:%.*]] = call i32 @gen32()
; CHECK-NEXT:    [[T0:%.*]] = lshr i32 [[X]], 1
; CHECK-NEXT:    call void @use32(i32 [[T0]])
; CHECK-NEXT:    [[TMP1:%.*]] = lshr i32 [[X]], 2
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], [[Y:%.*]]
; CHECK-NEXT:    [[TMP3:%.*]] = icmp ne i32 [[TMP2]], 0
; CHECK-NEXT:    ret i1 [[TMP3]]
;
  %x = call i32 @gen32()
  %t0 = lshr i32 %x, 1
  call void @use32(i32 %t0)
  %t1 = shl i32 %y, 1
  %t2 = and i32 %t0, %t1 ; "swapped"
  %t3 = icmp ne i32 %t2, 0
  ret i1 %t3
}
define i1 @t37_commutativity1_oneuse1(i32 %y) {
; CHECK-LABEL: @t37_commutativity1_oneuse1(
; CHECK-NEXT:    [[X:%.*]] = call i32 @gen32()
; CHECK-NEXT:    [[T1:%.*]] = shl i32 [[Y:%.*]], 1
; CHECK-NEXT:    call void @use32(i32 [[T1]])
; CHECK-NEXT:    [[TMP1:%.*]] = lshr i32 [[X]], 2
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], [[Y]]
; CHECK-NEXT:    [[TMP3:%.*]] = icmp ne i32 [[TMP2]], 0
; CHECK-NEXT:    ret i1 [[TMP3]]
;
  %x = call i32 @gen32()
  %t0 = lshr i32 %x, 1
  %t1 = shl i32 %y, 1
  call void @use32(i32 %t1)
  %t2 = and i32 %t0, %t1 ; "swapped"
  %t3 = icmp ne i32 %t2, 0
  ret i1 %t3
}

; Negative tests
define <2 x i1> @n38_overshift(<2 x i32> %x, <2 x i32> %y) {
; CHECK-LABEL: @n38_overshift(
; CHECK-NEXT:    [[T0:%.*]] = lshr <2 x i32> [[X:%.*]], <i32 15, i32 1>
; CHECK-NEXT:    [[T1:%.*]] = shl <2 x i32> [[Y:%.*]], <i32 17, i32 1>
; CHECK-NEXT:    [[T2:%.*]] = and <2 x i32> [[T1]], [[T0]]
; CHECK-NEXT:    [[T3:%.*]] = icmp ne <2 x i32> [[T2]], zeroinitializer
; CHECK-NEXT:    ret <2 x i1> [[T3]]
;
  %t0 = lshr <2 x i32> %x, <i32 15, i32 1>
  %t1 = shl <2 x i32> %y, <i32 17, i32 1>
  %t2 = and <2 x i32> %t1, %t0
  %t3 = icmp ne <2 x i32> %t2, <i32 0, i32 0>
  ret <2 x i1> %t3
}

; As usual, don't crash given constantexpr's :/
@f.a = internal global i16 0
define i1 @constantexpr() {
; CHECK-LABEL: @constantexpr(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = load i16, i16* @f.a, align 2
; CHECK-NEXT:    [[TMP1:%.*]] = lshr i16 [[TMP0]], 1
; CHECK-NEXT:    [[TMP2:%.*]] = and i16 [[TMP1]], shl (i16 1, i16 zext (i1 icmp ne (i16 ptrtoint (i16* @f.a to i16), i16 1) to i16))
; CHECK-NEXT:    [[TOBOOL:%.*]] = icmp ne i16 [[TMP2]], 0
; CHECK-NEXT:    ret i1 [[TOBOOL]]
;
entry:
  %0 = load i16, i16* @f.a
  %shr = ashr i16 %0, 1
  %shr1 = ashr i16 %shr, zext (i1 icmp ne (i16 ptrtoint (i16* @f.a to i16), i16 1) to i16)
  %and = and i16 %shr1, 1
  %tobool = icmp ne i16 %and, 0
  ret i1 %tobool
}

; See https://bugs.llvm.org/show_bug.cgi?id=44802
define i1 @pr44802(i3 %a, i3 %x, i3 %y) {
; CHECK-LABEL: @pr44802(
; CHECK-NEXT:    [[T0:%.*]] = icmp ne i3 [[A:%.*]], 0
; CHECK-NEXT:    [[T1:%.*]] = zext i1 [[T0]] to i3
; CHECK-NEXT:    [[T2:%.*]] = lshr i3 [[X:%.*]], [[T1]]
; CHECK-NEXT:    [[T3:%.*]] = shl i3 [[Y:%.*]], [[T1]]
; CHECK-NEXT:    [[T4:%.*]] = and i3 [[T2]], [[T3]]
; CHECK-NEXT:    [[T5:%.*]] = icmp ne i3 [[T4]], 0
; CHECK-NEXT:    ret i1 [[T5]]
;
  %t0 = icmp ne i3 %a, 0
  %t1 = zext i1 %t0 to i3
  %t2 = lshr i3 %x, %t1
  %t3 = shl i3 %y, %t1
  %t4 = and i3 %t2, %t3
  %t5 = icmp ne i3 %t4, 0
  ret i1 %t5
}
