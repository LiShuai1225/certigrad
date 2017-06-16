/-
Copyright (c) 2017 Daniel Selsam. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Author: Daniel Selsam

Proofs that integrating out the KL and reparametizing are sound when
applied to the naive variational encoder.
-/
import .util .naive ..prove_model_ok ..pre .sub_exp

set_option class.instance_max_depth 100000
set_option max_memory 100000
set_option pp.max_depth 100000

namespace certigrad
namespace aevb

-- TODO(dhs): take decidable instance, put this somewhere else
instance decidable_ref_subset {α : Type*} [decidable_eq α] {xs ys : list α} : decidable (xs ⊆ ys) :=
begin
dunfold has_subset.subset list.subset,
apply_instance
end

section proofs
open graph list tactic certigrad.tactic

parameters (a : arch) (ws : weights a) (x_data : T [a^.n_in, a^.n_x])
def g : graph := reparam (integrate_kl $ graph_naive a x_data)
def fdict : env := mk_input_dict ws g

attribute [cgsimp] g fdict

lemma g_final_nodups : nodup (env.keys fdict ++ map node.ref g^.nodes) := sorry --by cgsimp

lemma g_final_ps_in_env : all_parents_in_env fdict g^.nodes := sorry --by cgsimp

lemma g_final_costs_scalars : all_costs_scalars g^.costs g^.nodes := sorry --by cgsimp

lemma g_final_env_has_key_he : env.has_key (ID.str label.W_encode, [a^.ne, a^.n_in]) fdict := sorry --by cgsimp

lemma g_final_tgt_cost_scalar_he : (ID.str label.W_encode ∈ g^.costs) → [a^.ne, a^.n_in] = [] := sorry --by cgsimp

lemma g_final_tgt_wf_at_he : well_formed_at g^.costs g^.nodes fdict (ID.str label.W_encode, [a^.ne, a^.n_in]) := sorry -- by constructor >> all_goals cgsimp

lemma g_final_tgts_in_inputs : g^.targets ⊆ env.keys fdict := sorry --by cgsimp

lemma g_final_pdfs_exist_at : pdfs_exist_at g^.nodes fdict := sorry --by cgsimp

-- TODO(dhs): The tactic is fast, but have yet to finish type-checking the proof
lemma g_final_grads_exist_at_he : grads_exist_at g^.nodes fdict (ID.str label.W_encode, [a^.ne, a^.n_in]) := sorry --by cgsimp


lemma g_final_is_gintegrable_he :
  is_gintegrable (λ m, ⟦compute_grad_slow g^.costs g^.nodes m (ID.str label.W_encode, [a^.ne, a^.n_in])⟧)
                 fdict g^.nodes dvec.head := sorry --by cgsimp >> prove_is_mvn_integrable
-- TODO(dhs): the type-checking crashes my machine

lemma g_final_diff_under_int_hem :
  can_differentiate_under_integrals g^.costs g^.nodes fdict (ID.str label.W_encode, [a^.nz, a^.ne]) := sorry -- by cgsimp
-- TODO(dhs): I don't know if this works or not, it takes freaking forever



end proofs


end aevb
end certigrad
