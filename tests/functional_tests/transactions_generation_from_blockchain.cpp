// Copyright (c) 2023-2024 Beezy Network
// Copyright (c) 2014-2018 The Louisdor Project
// Copyright (c) 2012-2013 The Cryptonote developers
// Distributed under the MIT/X11 software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#include "include_base_utils.h"
using namespace epee;
#include "wallet/wallet2.h"
#include "currency_core/blockchain_storage.h"

using namespace currency;

/*
bool transactions_generation_from_blockchain(std::string& blockchain_folder_path)
{
  string_tools::parse_hexstr_to_binbuff()
  tx_memory_pool pool;
  blockchain_storage bchs(pool);
  bool r = bchs.init(blockchain_folder_path);
  CHECK_AND_ASSERT_MES(r, false, "failed to load blockchain");

  //amount = 3000000000000
  //key_offsets = 1,2,3,4,5,10,12,27,31,33,34
  //
}

tx_source_entry::output_entry make_outptu_entr_for_gindex(size_t i, std::map<crypto::hash, transaction>& txs, std::vector<std::pair<crypto::hash, size_t> >& v)
{
  tx_source_entry::output_entry oe;
  oe = i;
  oe.second = txs[v[i].first].boost::get<txout_to_key>(vout[v[i].second].target).key;
  return oe;
}

bool make_tx(blockchain_storage& bch)
{
  std::map<crypto::hash, transaction> txs;
  std::vector<std::pair<crypto::hash, size_t> > v;
  bch.get_outs_for_amounts(3000000000000, v);

  std::vector<tx_source_entry> sources(11);
  sources[0].amount = 3000000000000;
  sources[0].outputs.push_back(make_outptu_entr_for_gindex(1, txs, v));
  sources[0].outputs.push_back(make_outptu_entr_for_gindex(2, txs, v));
  sources[0].outputs.push_back(make_outptu_entr_for_gindex(3, txs, v));
  sources[0].outputs.push_back(make_outptu_entr_for_gindex(4, txs, v));
  sources[0].outputs.push_back(make_outptu_entr_for_gindex(5, txs, v));
  sources[0].outputs.push_back(make_outptu_entr_for_gindex(10, txs, v));
  sources[0].outputs.push_back(make_outptu_entr_for_gindex(12, txs, v));
  sources[0].outputs.push_back(make_outptu_entr_for_gindex(27, txs, v));
  sources[0].outputs.push_back(make_outptu_entr_for_gindex(31, txs, v));
  sources[0].outputs.push_back(make_outptu_entr_for_gindex(33, txs, v));
  sources[0].outputs.push_back(make_outptu_entr_for_gindex(34, txs, v));
  sources[0].real_out_tx_key =

  BOOST_FOREACH(transfer_container::iterator it, selected_transfers)
  {
    sources.resize(sources.size()+1);
    currency::tx_source_entry& src = sources.back();
    transfer_details& td = *it;
    src.amount = td.m_tx.vout[td.m_internal_output_index].amount;
    //paste mixin transaction
    if(daemon_resp.outs.size())
    {
      daemon_resp.outs[i].outs.sort([](const out_entry& a, const out_entry& b){return a.global_amount_index < b.global_amount_index;});
      BOOST_FOREACH(out_entry& daemon_oe, daemon_resp.outs[i].outs)
      {
        if(td.m_global_output_index == daemon_oe.global_amount_index)
          continue;
        tx_output_entry oe;
        oe.first = daemon_oe.global_amount_index;
        oe.second = daemon_oe.out_key;
        src.outputs.push_back(oe);
        if(src.outputs.size() >= fake_outputs_count)
          break;
      }
    }

    //paste real transaction to the random index
    auto it_to_insert = std::find_if(src.outputs.begin(), src.outputs.end(), [&](const tx_output_entry& a)
    {
      return a.first >= td.m_global_output_index;
    });
    //size_t real_index = src.outputs.size() ? (rand() % src.outputs.size() ):0;
    tx_output_entry real_oe;
    real_oe.first = td.m_global_output_index;
    real_oe.second = boost::get<txout_to_key>(td.m_tx.vout[td.m_internal_output_index].target).key;
    auto interted_it = src.outputs.insert(it_to_insert, real_oe);
    src.real_out_tx_key = td.m_tx.tx_pub_key;
    src.real_output = interted_it - src.outputs.begin();
    src.real_output_in_tx_index = td.m_internal_output_index;
    ++i;
  }


  if(found_money != needed_money)
  {
    //lets make last output to odd money
    dsts.resize(dsts.size()+1);
    currency::tx_destination_entry& destination = dsts.back();
    CHECK_AND_ASSERT_MES(found_money > needed_money, false, "internal error found_money=" << found_money << " !> needed_money=" << needed_money);
    destination.amount = found_money - needed_money;
  }


  transaction tx;
  bool r = currency::construct_tx(m_account.get_keys(), sources, dsts, tx, unlock_time);
  if(!r)
  {
    std::cout << "transaction construction failed" << std::endl;
  }

  COMMAND_RPC_SEND_RAW_TX::request req;
  req.tx_as_hex = epee::string_tools::buff_to_hex_nodelimer(tx_to_blob(tx));
  COMMAND_RPC_SEND_RAW_TX::response daemon_send_resp;
  r = net_utils::http::invoke_http_json_remote_command(m_daemon_address + "/sendrawtransaction", req, daemon_send_resp, m_http_client);
  CHECK_AND_ASSERT_MES(r, false, "failed to send transaction");
  if(daemon_send_resp.status != CORE_RPC_STATUS_OK)
  {
    std::cout << "daemon failed to accept generated transaction" << ENDL;
    return false;
  }

  std::cout << "transaction generated ok and sent to daemon" << std::endl;
  BOOST_FOREACH(transfer_container::iterator it, selected_transfers)
    it->m_spent = true;

  return true;
}*/
