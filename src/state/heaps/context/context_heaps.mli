(*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *)

module type READER = sig
  type reader

  val get_leader : reader:reader -> File_key.t -> File_key.t option

  val get_leader_unsafe : reader:reader -> File_key.t -> File_key.t

  val find_master : reader:reader -> Context.master_context
end

module Mutator_reader : sig
  include READER with type reader = Mutator_state_reader.t

  val sig_hash_changed : reader:reader -> File_key.t -> bool
end

module Reader : READER with type reader = State_reader.t

module Reader_dispatcher : READER with type reader = Abstract_state_reader.t

module Init_master_context_mutator : sig
  val add_master : (Context.t -> unit) Expensive.t
end

module Merge_context_mutator : sig
  type master_mutator

  type worker_mutator

  val create : Transaction.t -> Utils_js.FilenameSet.t -> master_mutator * worker_mutator

  val add_merge_on_diff : worker_mutator -> File_key.t Nel.t -> Xx.hash -> bool

  val revive_files : master_mutator -> Utils_js.FilenameSet.t -> unit
end
