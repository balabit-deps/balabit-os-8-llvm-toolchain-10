; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -scalarizer -S -o - | FileCheck %s

define i16 @f1() {
; CHECK-LABEL: @f1(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[FOR_END:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[INSERT:%.*]] = insertelement <4 x i16> [[INSERT]], i16 ptrtoint (i16 ()* @f1 to i16), i32 0
; CHECK-NEXT:    br label [[FOR_COND:%.*]]
; CHECK:       for.cond:
; CHECK-NEXT:    br i1 undef, label [[FOR_BODY:%.*]], label [[FOR_END]]
; CHECK:       for.end:
; CHECK-NEXT:    [[PHI_I0:%.*]] = phi i16 [ 1, [[ENTRY:%.*]] ], [ undef, [[FOR_COND]] ]
; CHECK-NEXT:    [[PHI_I1:%.*]] = phi i16 [ 1, [[ENTRY]] ], [ undef, [[FOR_COND]] ]
; CHECK-NEXT:    [[PHI_I2:%.*]] = phi i16 [ 1, [[ENTRY]] ], [ undef, [[FOR_COND]] ]
; CHECK-NEXT:    [[PHI_I3:%.*]] = phi i16 [ 1, [[ENTRY]] ], [ undef, [[FOR_COND]] ]
; CHECK-NEXT:    [[PHI_UPTO0:%.*]] = insertelement <4 x i16> undef, i16 [[PHI_I0]], i32 0
; CHECK-NEXT:    [[PHI_UPTO1:%.*]] = insertelement <4 x i16> [[PHI_UPTO0]], i16 [[PHI_I1]], i32 1
; CHECK-NEXT:    [[PHI_UPTO2:%.*]] = insertelement <4 x i16> [[PHI_UPTO1]], i16 [[PHI_I2]], i32 2
; CHECK-NEXT:    [[PHI:%.*]] = insertelement <4 x i16> [[PHI_UPTO2]], i16 [[PHI_I3]], i32 3
; CHECK-NEXT:    [[EXTRACT:%.*]] = extractelement <4 x i16> [[PHI]], i32 0
; CHECK-NEXT:    ret i16 [[EXTRACT]]
;
entry:
  br label %for.end

for.body:
  %insert = insertelement <4 x i16> %insert, i16 ptrtoint (i16 () * @f1 to i16), i32 0
  br label %for.cond

for.cond:
  br i1 undef, label %for.body, label %for.end

for.end:
  ; opt used to hang when scalarizing this code. When scattering %insert we
  ; need to analyze the insertelement in the unreachable-from-entry block
  ; for.body. Note that the insertelement instruction depends on itself, and
  ; this kind of IR is not allowed in reachable-from-entry blocks.
  %phi = phi <4 x i16> [ <i16 1, i16 1, i16 1, i16 1>, %entry ], [ %insert, %for.cond ]
  %extract = extractelement <4 x i16> %phi, i32 0
  ret i16 %extract
}

define void @f2() {
; CHECK-LABEL: @f2(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    br i1 undef, label [[IF_THEN:%.*]], label [[IF_END8:%.*]]
; CHECK:       if.then:
; CHECK-NEXT:    br label [[IF_END8]]
; CHECK:       for.body2:
; CHECK-NEXT:    br i1 undef, label [[FOR_END:%.*]], label [[FOR_INC:%.*]]
; CHECK:       for.end:
; CHECK-NEXT:    br label [[FOR_INC]]
; CHECK:       for.inc:
; CHECK-NEXT:    [[E_SROA_3_2:%.*]] = phi <2 x i64> [ <i64 1, i64 1>, [[FOR_END]] ], [ [[E_SROA_3_2]], [[FOR_BODY2:%.*]] ]
; CHECK-NEXT:    [[TMP0:%.*]] = phi i32 [ 6, [[FOR_END]] ], [ [[TMP0]], [[FOR_BODY2]] ]
; CHECK-NEXT:    br i1 undef, label [[FOR_BODY2]], label [[FOR_COND1_FOR_END7_CRIT_EDGE:%.*]]
; CHECK:       for.cond1.for.end7_crit_edge:
; CHECK-NEXT:    br label [[IF_END8]]
; CHECK:       if.end8:
; CHECK-NEXT:    [[E_SROA_3_4_I0:%.*]] = phi i64 [ undef, [[FOR_BODY]] ], [ undef, [[FOR_COND1_FOR_END7_CRIT_EDGE]] ], [ undef, [[IF_THEN]] ]
; CHECK-NEXT:    [[E_SROA_3_4_I1:%.*]] = phi i64 [ undef, [[FOR_BODY]] ], [ undef, [[FOR_COND1_FOR_END7_CRIT_EDGE]] ], [ undef, [[IF_THEN]] ]
; CHECK-NEXT:    br label [[FOR_BODY]]
;
entry:
  br label %for.body

for.body:                                         ; preds = %if.end8, %entry
  br i1 undef, label %if.then, label %if.end8

if.then:                                          ; preds = %for.body
  br label %if.end8

for.body2:                                        ; preds = %for.inc
  br i1 undef, label %for.end, label %for.inc

for.end:                                          ; preds = %for.body2
  br label %for.inc

for.inc:                                          ; preds = %for.end, %for.body2
  %e.sroa.3.2 = phi <2 x i64> [ <i64 1, i64 1>, %for.end ], [ %e.sroa.3.2, %for.body2 ]
  %0 = phi i32 [ 6, %for.end ], [ %0, %for.body2 ]
  br i1 undef, label %for.body2, label %for.cond1.for.end7_crit_edge

for.cond1.for.end7_crit_edge:                     ; preds = %for.inc
  br label %if.end8

if.end8:                                          ; preds = %for.cond1.for.end7_crit_edge, %if.then, %for.body
  ; This used to lead to inserted extractelement instructions between the phis
  ; in %for.inc.
  ; %e.sroa.3.2 is defined in a block that is unreachable from entry so we can
  ; safely replace it with undef in the phi defining e.sroa.3.4.
  %e.sroa.3.4 = phi <2 x i64> [ undef, %for.body ], [ %e.sroa.3.2, %for.cond1.for.end7_crit_edge ], [ undef, %if.then ]
  br label %for.body
}
